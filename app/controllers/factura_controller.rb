class FacturaController < ApplicationController
  # Incluimos esto para un trucate en los tickets
  include ActionView::Helpers::TextHelper

  # Librerias para PDF
  require 'pdf/writer'
  require 'pdf/simpletable'

  # Librerias para paginado
  require 'will_paginate'

  # Hace una busqueda de "factura" para listado 
  before_filter :obtiene_facturas, :only => [ :listado, :aceptar_cobro ]

  def index
    redirect_to :action => :listado
  end

  def listado
    @formato_xls = @facturas.total_entries
    respond_to do |format|
      format.html
      format.xls do
        @tipo = "facturas_" + params[:seccion]
        @objetos = @facturas
        render 'comunes_xls/listado', :layout => false
      end
    end
  end

  def editar
    @factura = params[:id] ? Factura.find(params[:id]) : nil 
    @albaran = @factura.albaran if @factura 
    if params[:seccion] == "tesoreria"
      @proveedores = Proveedor.find :all, :order => 'nombre'
      @ivas = Iva.all
    end
    @clientes = Cliente.all if params[:seccion] == "caja"
    render :partial => "formulario", :locals => { :proveedor => (@albaran.proveedor.nombre if @albaran && @albaran.proveedor_id) }
  end

  def modificar
    factura = params[:id] ? Factura.find(params[:id]) : Factura.new
    # Para caja, actualizamos el cliente en el albaran
    if params[:seccion] == "caja"
      albaran = factura.albaran
      albaran.update_attributes params[:albaran]
    # Para productos comprobamos si queremos pisar los importes
    elsif params[:seccion] == "productos"
      unless params[:selector][:fuerza_importe] == "1" && params[:factura][:importe_base] && params[:factura][:importe_base].to_f.abs < params[:factura][:importe].to_f.abs
        params[:factura][:importe_base] = nil
        params[:factura][:importe] = factura.albaran.total
      end
    # Para tesoreria actualizamos los campos
    elsif params[:seccion] == "tesoreria"
      # Guardamos 2 veces en el caso de tesoreria para poder hacer el calculo segun la base imponible
      factura.update_attributes params[:factura]
    end
    # Guardamos las modificaciones
    factura.update_attributes params[:factura]
    flash[:error] = factura
    redirect_to :action => :listado
  end

  def aceptar_albaran_proveedor
    albaran = Albaran.find_by_id params[:albaran_id]
    # Genera una factura solo si no es de deposito
    if !albaran.deposito
      factura = Factura.new
      factura.fecha = Time.now
      factura.albaran_id = params[:albaran_id]
      factura.codigo = "N/A"
      factura.importe = params[:importe].to_f
      factura.save
    end
    redirect_to :controller => :albarans, :action => :aceptar_albaran, :id => params[:albaran_id]
  end

  def borrar 
    factura = Factura.find(params[:id])

    # Cuando no son facturas externas hay que modificar el inventario
    if params[:seccion] != "tesoreria"
      albaran = factura.albaran
      albaran.reabrir(params[:seccion]) if factura.destroy
    else
      factura.destroy
    end
    flash[:error] = factura 
    redirect_to :action => :listado
  end

  def cobrar_albaran
    @factura = Factura.new
    @formasdepago = FormaPago.all
    @importe = params[:importe]
    render :partial => "cobrar_albaran", :albaran_id => params[:albaran_id]
  end

  def aceptar_cobro
    factura = Factura.new
    factura.pagado = true
    factura.codigo = codigo_factura_venta
    factura.fecha = Time.now
    factura.update_attributes params[:factura]
    flash[:error] = factura
    pago = Pago.new
    pago.importe = factura.importe
    pago.factura = factura
    pago.fecha = Time.now 
    pago.forma_pago_id = params[:forma_pago][:id]
    pago.save
    imprime_ticket( factura.albaran_id, FormaPago.find_by_id(params[:forma_pago][:id]).nombre) if params[:imprimeticket][:imprimeticket] == "true"
    redirect_to :controller => :albarans, :action => :aceptar_albaran, :id => factura.albaran_id, :forma_pago => params[:forma_pago], :importe => params[:importe], :recibido => params[:recibido]
  end

  def calcula_cambio
    devolver = params[:recibido].to_f - params[:importe].to_f
    render :inline => devolver>=0 ? 'A Devolver<br/>' + format("%.2f",devolver.to_s) + ' €' : '&nbsp;'
  end

  def imprimir
    factura = params[:id] ? Factura.find_by_id(params[:id]) : nil
    if factura && factura.pagado && factura.albaran && factura.albaran.cliente
      send_data genera_pdf(factura), :filename => 'Factura.' + factura.codigo + '.pdf', :type => 'application/pdf'
      #redirect_to :action => :listado
    else
      flash[:error] = "Imposible imprimir. La factura no existe o no está completamente pagada."
      redirect_to :action => :listado
    end
  end

private

  def obtiene_facturas 
    # Segun la seccion aplica un criterio de busqueda con los filtrados particulares
    case params[:seccion]
      when "caja"
        condicion = "albarans.cliente_id IS NOT NULL" unless session[("filtrado_cliente").to_sym] && session[("filtrado_cliente").to_sym] != ""
        condicion = "albarans.cliente_id = " + session[("filtrado_cliente").to_sym] if session[("filtrado_cliente").to_sym] && session[("filtrado_cliente").to_sym] != ""
      when "productos"
        condicion = "albarans.proveedor_id IS NOT NULL" unless session[("filtrado_proveedor").to_sym] && session[("filtrado_proveedor").to_sym] != ""
        condicion = "albarans.proveedor_id = " + session[("filtrado_proveedor").to_sym] if session[("filtrado_proveedor").to_sym] && session[("filtrado_proveedor").to_sym] != ""
      when "tesoreria"
        condicion = "albaran_id IS NULL"
      when "trueke"
        condicion = "albarans.cliente_id IS NOT NULL"
    end
    # Si hay un filtrado de fechas lo aplica
    if cookies[("filtrado_fecha_inicio").to_sym] && cookies[("filtrado_fecha_fin").to_sym]
      condicion += " AND facturas.fecha BETWEEN '" + cookies[("filtrado_fecha_inicio").to_sym] + "' AND '" + cookies[("filtrado_fecha_fin").to_sym] + "'"
    end
    # Si hay filtrado de facturas pagadas lo aplica
    if session[("filtrado_pagado").to_sym] && session[("filtrado_pagado").to_sym] != ""
      condicion += " AND facturas.pagado IS " + session[("filtrado_pagado").to_sym]
    end

    @facturas = Factura.paginate( :order => 'facturas.fecha DESC, facturas.codigo DESC', :include => "albaran", :conditions => [ condicion ],
        :page => (params[:format]=='xls' ? nil : params[:page]), :per_page => (params[:format_xls_count] || Configuracion.valor('PAGINADO') ))
  end

  def genera_pdf factura
    columnas = [	{ :atribute => "cantidad", :title => '', :width => 20, :align => :right },
			{ :atribute => "nombre_producto", :title => 'Nombre', :width => 180 },
			{ :atribute => "precio_venta", :title => 'PVP', :width => 50, :format => "%.2f", :align => :right },
			{ :atribute => "descuento", :title => '%Dto', :width => 35, :align => :right },
			{ :atribute => "subtotal", :title => 'B.Imp.', :width => 50, :format => "%.2f", :align => :right },
			{ :atribute => "iva", :title => '%IVA', :width => 35, :align => :right },
			{ :atribute => "total", :title => 'Total', :width => 50, :format => "%.2f", :align => :right } ]

    pdf = PDF::Writer.new(:paper => 'A4')
    pdf.select_font"Helvetica"
    pdf.margins_mm(30)
    pdf.font_size = 9
    pdf.start_columns 3
    pdf.image "public/images/logo_factura.png"
    pdf.start_new_page
    pdf.start_new_page
    pdf.move_pointer(15)
    pdf.text Configuracion.valor('NOMBRE CORTO EMPRESA').upcase
    pdf.text Configuracion.valor('NOMBRE LARGO EMPRESA')
    pdf.text "C.I.F. " + Configuracion.valor('CIF')
    pdf.text Configuracion.valor('DIRECCION') if Configuracion.valor('DIRECCION')
    pdf.text Configuracion.valor('CODIGO POSTAL') if Configuracion.valor('CODIGO POSTAL')
    pdf.text "Tfn. " + Configuracion.valor('TELEFONO') if Configuracion.valor('TELEFONO')
    pdf.stop_columns
    pdf.move_pointer(30)
    pdf.start_columns 3
    pdf.text "Fecha: " + factura.fecha.to_s
    pdf.text "Factura num.: " + factura.codigo
    pdf.start_new_page
    pdf.start_new_page
    pdf.text "Cliente: " + factura.albaran.cliente.nombre 
    pdf.text "N.I.F. " + factura.albaran.cliente.cif
    pdf.text factura.albaran.cliente.direccion if factura.albaran.cliente.direccion
    pdf.text factura.albaran.cliente.cp if factura.albaran.cliente.cp 
    pdf.stop_columns
    pdf.move_pointer(30) 
    iva_total = {}
    subtotal = precio_total = 0
    PDF::SimpleTable.new do |tab|
      #tab.show_lines = :all
      tab.show_headings = true
      tab.bold_headings = true
      tab.orientation = :center
      tab.font_size = 9
      tab.heading_font_size = 9 
      tab.shade_color = Color::RGB::Grey90
      tab.column_order = columnas.collect { |columna| columna[:atribute] } 
      columnas.each do |columna|
        tab.columns[columna[:atribute]] = PDF::SimpleTable::Column.new(columna[:atribute]) { |col|
          col.width = columna[:width]
          col.heading = columna[:title]
          col.heading.justification = :center
          col.justification = columna[:align] if columna[:align]
        }
      end
      data = []
      factura.albaran.albaran_lineas.each do |linea|
        fila = Hash.new
        columnas.each do |columna|
          fila[columna[:atribute]] = columna[:format] ? format(columna[:format],linea.send(columna[:atribute])) : linea.send(columna[:atribute])
        end
        iva = linea.iva
        iva_total[iva] = iva_total.key?(iva) ? iva_total[iva] + (linea.total-linea.subtotal) : linea.total-linea.subtotal
        subtotal += linea.subtotal
        precio_total += linea.total
        data << fila 
      end
      tab.data.replace data
      tab.render_on(pdf)
    end
    pdf.move_pointer(9)
    PDF::SimpleTable.new do |tab|
      tab.show_lines = :none
      tab.orientation = :center
      tab.show_headings = false
      tab.shade_rows = :none
      tab.font_size = 10 
      tab.column_order = [ "vacio","atributo","valor" ]
      tab.columns["vacio"] = PDF::SimpleTable::Column.new("vacio") { |col| col.width = 180 }
      tab.columns["atributo"] = PDF::SimpleTable::Column.new("atributo") { |col|
        col.width = 200
        col.justification = :left
      }
      tab.columns["valor"] = PDF::SimpleTable::Column.new("valor") { |col|
        col.width = 50
        col.justification = :right
      }
      data = []
      data << {  "atributo" => "Subtotal", "valor" => format("%.2f",subtotal) } 
      iva_total.each do |tipo,parcial|
        data << { "atributo" => "IVA " + tipo.to_s + "%", "valor" => format("%.2f",parcial) } 
      end
      data << { "atributo" => "Total Euros (IVA incluido)", "valor" => format("%.2f",precio_total) } 
      tab.data.replace data
      tab.render_on(pdf) 
    end
    return pdf.render
  end

  def codigo_factura_venta
    codigo = 0 
    prefijo = Configuracion.valor("PREFIJO FACTURA VENTA")
    @facturas.each do |factura|
      nuevo_codigo = /^#{prefijo}([0-9]+)$/.match(factura.codigo)
      codigo = nuevo_codigo[1].to_i if nuevo_codigo && nuevo_codigo[1] && nuevo_codigo[1].to_i > codigo
    end 
    return prefijo + format("%010d", (codigo+1).to_s)
  end

  def imprime_ticket albaran_id, formadepago
    albaran = Albaran.find_by_id albaran_id
    lineas = albaran.albaran_lineas
    precio_total = 0
    subtotal = 0
    iva_total={}

    nombre_corto = "| " + Configuracion.valor('NOMBRE CORTO EMPRESA') + " |"
    pre_size = (46 - nombre_corto.length.to_i) / 2
    cadena  = " " * pre_size + "-" * nombre_corto.length.to_i + "\n"
    cadena += " " * pre_size + nombre_corto + "\n"
    cadena += " " * pre_size + "-" * nombre_corto.length.to_i + "\n\n"
    cadena += " " + Configuracion.valor('NOMBRE LARGO EMPRESA') + "\n"
    cadena += " C.I.F. " + Configuracion.valor('CIF') + "\n"
    cadena += " " + Configuracion.valor('DIRECCION') + "\n\n" 
    cadena += " Cliente: " + albaran.cliente.nombre + "\n"
    cadena += " Fecha: " + Time.now.strftime("%d-%m-%Y  %H:%M") + "\n"
    cadena += " Ticket: " + albaran.factura.codigo + "\n"
    cadena += " Forma de Pago: " + formadepago + "\n\n"
    cadena += "--------------------------------------------------\n\n"
    cadena += format "Cnt.  %-31s Dto.   Imp.\n\n", "Descripcion"
    lineas.each do |linea|
      cantidad = linea.cantidad
      descuento = linea.descuento
      nombre = truncate(linea.nombre_producto, :length => 31)
      iva = linea.iva
      iva_total[iva] = iva_total.key?(iva) ? iva_total[iva] + (linea.total-linea.subtotal) : linea.total-linea.subtotal 
      subtotal += linea.subtotal 
      precio_total += linea.total 
      cadena += format " %2d  %-32s  %2d  %6s\n", cantidad, nombre, descuento, format("%.2f",linea.total)
    end
    cadena += "\n--------------------------------------------------\n\n"
    cadena += format " %-41s %6s\n", "Subtotal", format("%.2f",subtotal)
    iva_total.each do |tipo,parcial|
      cadena += format " %-41s %6s\n", format("Iva ( %2s%% )",tipo.to_s), format("%.2f",parcial)
    end
    cadena += format "\n %-41s %6s\n\n.", "Total Euros (IVA incluido)", format("%.2f",precio_total.to_s)
    File.open("/tmp/ticket", 'w') {|f| f.write(cadena) }
    #system("lpr -P " + Configuracion.valor('IMPRESORA') + " -o cpi=20 " + " /tmp/ticket")
    system(Configuracion.valor('COMANDO IMPRESION') + " /tmp/ticket")
  end

end
