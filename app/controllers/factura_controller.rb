# encoding: UTF-8

class FacturaController < ApplicationController
  # Incluimos esto para un trucate en los tickets
  include ActionView::Helpers::TextHelper

  # Hace una busqueda de "factura" para listado 
  before_filter :obtiene_facturas, :only => [ :listado, :aceptar_cobro ]

  def index
    flash[:mensaje] = "Listado de Facturas de Proveedores" if params[:seccion] == "productos"
    flash[:mensaje] = "Listado de Facturas de Clientes" if params[:seccion] == "caja"
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
    @factura = Factura.find_by_id(params[:id])
    @albaran = @factura.albarans.first if @factura 
    if params[:seccion] == "tesoreria"
      @proveedores = Proveedor.find :all, :order => 'nombre'
      @ivas = Iva.all
    end
    @clientes = Cliente.all if params[:seccion] == "caja"
    render :partial => "formulario", :locals => { :proveedor => (@albaran.proveedor.nombre if @albaran && @albaran.proveedor_id) }
  end

  def modificar
    factura = Factura.find_by_id(params[:id]) || Factura.new
    # Para caja, actualizamos el cliente en el albaran
    if params[:seccion] == "caja"
      factura.albarans.each { |albaran| albaran.update_attributes params[:albaran] }
    # Para productos comprobamos si queremos pisar los importes
    elsif params[:seccion] == "productos"
      unless params[:selector][:fuerza_importe] == "1" && params[:factura][:importe_base] && params[:factura][:importe_base].to_f.abs < params[:factura][:importe].to_f.abs
        params[:factura][:importe_base] = nil
        params[:factura][:importe] = factura.albarans.inject(0) {|sum,alb| sum+alb.total}
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

  def borrar 
    factura = Factura.find_by_id(params[:id])

    # Cuando no son facturas externas hay que modificar el inventario
    if params[:seccion] == "caja"
      albarans = factura.albarans
      albarans.each {|alb| alb.reabrir(params[:seccion])} if factura.destroy
    else
      factura.albarans.each do |alb|
        alb.factura_id = nil
        alb.save
      end if factura.destroy
    end
    flash[:error] = factura if factura.errors.empty?
    flash[:error] = factura.errors.collect{|k,v| v}.join("<br>".html_safe) unless factura.errors.empty?
    redirect_to :action => :listado
  end

  # Genera un albaran desde los de la factura indicada
  def copiar
    factura = Factura.find_by_id(params[:id])
    albaran_nuevo = nil
    factura.albarans.each { |albaran_factura| albaran_nuevo = albaran_factura.clonar(albaran_nuevo) } if factura
    redirect_to :controller => :albarans, :action => :editar, :id => albaran_nuevo.id if albaran_nuevo.id
    flash[:error] = "Problemas copiando factura" unless albaran_nuevo.id
    redirect_to :controller => :factura unless albaran_nuevo.id
  end

  def cobrar_albaran
    @factura = Factura.new
    @formasdepago = FormaPago.all
    @importe = params[:importe]
    render :partial => "cobrar_albaran", :albaran_id => params[:albaran_id]
  end

  def aceptar_cobro
    albaran = Albaran.find_by_id params[:albaran_id]
    if albaran
      factura = Factura.new
      factura.pagado = true
      factura.codigo = "PENDIENTE"
      factura.fecha = Time.now
      factura.albarans << albaran
      factura.update_attributes params[:factura]
      flash[:error] = factura unless factura.errors.empty?
      if factura.errors.empty?
        pago = Pago.new
        pago.importe = factura.importe
        pago.factura = factura
        pago.fecha = Time.now 
        pago.forma_pago_id = params[:forma_pago][:id]
        pago.save
        imprime_ticket( albaran.id, pago.forma_pago.nombre) if params[:imprimeticket] && params[:imprimeticket][:imprimeticket] == "true"
        if ( pago.forma_pago && pago.forma_pago.caja )
          flash[:mensaje_ok] = ("Asegúrese de cobrar la venta!!!<div class='importe_medio'>Importe: " + params[:importe] + "€").html_safe
          flash[:mensaje_ok] << ("<br>Recibido: " + params[:recibido][0] + "€<br>Cambio: " + format("%.2f",(params[:recibido][0].to_f - params[:importe].to_f).to_s) + "€").html_safe if params[:recibido][0].to_f > 0
          flash[:mensaje_ok] << "</div>".html_safe
        else
          flash[:mensaje_ok] = "Pago realizado!"
        end
      end
    end
    redirect_to :controller => :albarans, :action => :aceptar_albaran, :albaran_id => params[:albaran_id], :forma_pago => params[:forma_pago], :importe => params[:importe], :recibido => params[:recibido], :mensaje_error => flash[:error], :mensaje_ok => flash[:mensaje_ok]
  end

  def calcula_cambio
    devolver = params[:recibido].to_f - params[:importe].to_f
    render :inline => devolver>=0 ? 'A Devolver<br/>' + format("%.2f",devolver.to_s) + ' €' : '&nbsp;'
  end

  def imprimir
    factura = Factura.find_by_id(params[:id])
    if factura && factura.pagado && !factura.albarans.empty? && factura.albarans.first.cliente
      pdf = FacturaPdf.new(factura, view_context)
      send_data pdf.render, filename: "Factura.#{factura.codigo}.pdf", type: 'application/pdf'
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
        #condicion = "albaran_id IS NULL"
        condicion = "facturas.proveedor_id IS NOT NULL"
      when "trueke"
        condicion = "albarans.cliente_id IS NOT NULL"
    end
    # Si hay un filtrado de fechas lo aplica
    if cookies[("filtrado_fecha_inicio").to_sym] && cookies[("filtrado_fecha_fin").to_sym]
      condicion += " AND facturas.fecha BETWEEN '" + cookies[("filtrado_fecha_inicio").to_sym] + "' AND '" + cookies[("filtrado_fecha_fin").to_sym] + "'" unless params[:seccion] == "productos" && cookies[("filtrado_tipo_fecha").to_sym] == "vencimiento"
      condicion += " AND facturas.fecha_vencimiento BETWEEN '" + cookies[("filtrado_fecha_inicio").to_sym] + "' AND '" + cookies[("filtrado_fecha_fin").to_sym] + "'" if params[:seccion] == "productos" && cookies[("filtrado_tipo_fecha").to_sym] == "vencimiento"
      #puts "-----------> Escogemos solo las facturas con fecha de vencimiento entre los margenes" if params[:seccion] == "productos" && cookies[("filtrado_tipo_fecha").to_sym] == "vencimiento"
    end
    # Si hay filtrado de facturas pagadas lo aplica
    if session[("filtrado_pagado").to_sym] && session[("filtrado_pagado").to_sym] != ""
      condicion += " AND facturas.pagado IS " + session[("filtrado_pagado").to_sym]
    end

    @facturas = Factura.joins(:albarans).where(condicion).order('facturas.fecha DESC, facturas.codigo DESC').
                        paginate( page: (params[:format]=='xls' ? nil : params[:page]),
                                  per_page: (params[:format_xls_count] || Configuracion.valor('PAGINADO')) )
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
