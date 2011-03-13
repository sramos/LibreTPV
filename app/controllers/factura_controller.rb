class FacturaController < ApplicationController

  # Hace una busqueda de "factura" para listado 
  before_filter :obtiene_facturas, :only => [ :listado, :aceptar_cobro ]

  def index
    flash[:mensaje] = "Listado de Facturas de Proveedores" if params[:seccion] == "productos"
    flash[:mensaje] = "Listado de Facturas de Clientes" if params[:seccion] == "caja"
    redirect_to :action => :listado
  end

  def listado
  end

  def editar
    @factura = Factura.find(params[:id])
    @albaran = @factura.albaran
    if params[:seccion] != "productos"
      @clientes = Cliente.all
    end
    render :partial => "formulario", :locals => { :proveedor => (@albaran.proveedor.nombre if @albaran.proveedor_id) }
  end

  def modificar
    if params[:seccion] != "productos"
      factura = Factura.find(params[:id])
      albaran = factura.albaran
      albaran.update_attributes params[:albaran]
      factura.update_attributes params[:factura]
      flash[:error] = factura
      redirect_to :action => :listado
    end
  end

  def aceptar_albaran_proveedor
    factura = Factura.new
    factura.fecha = Time.now
    factura.albaran_id = params[:albaran_id]
    factura.codigo = "N/A"
    factura.importe = params[:importe].to_f
    factura.save
    redirect_to :controller => :albarans, :action => :aceptar_albaran, :id => params[:albaran_id]
  end

  def cobrar_albaran
    @factura = Factura.new
    @importe = params[:importe]
    render :partial => "cobrar_albaran", :albaran_id => params[:albaran_id]
  end

  def aceptar_cobro
    factura = Factura.new
    factura.pagado = true
    factura.codigo = codigo_factura_venta
    factura.update_attributes params[:factura]
    flash[:error] = factura
    pago = Pago.new
    pago.importe = factura.importe
    pago.factura = factura
    pago.fecha = factura.fecha
    pago.save
    imprime_ticket factura.albaran_id
    redirect_to :controller => :albarans, :action => :aceptar_albaran, :id => factura.albaran_id
  end

  def calcula_cambio
    devolver = params[:recibido].to_f - params[:importe].to_f
    render :inline => devolver>=0 ? 'A Devolver<br/>' + devolver.to_s + ' €' : '&nbsp;'
  end

private

  def obtiene_facturas 
    # Hace una limpieza de los albaranes vacios
    case params[:seccion]
      when "caja"
        condicion = "cliente_id"
      when "productos"
        condicion = "proveedor_id"
      when "trueke"
        condicion = "cliente_id"
    end
    @facturas = Factura.find :all, :order => 'facturas.codigo DESC', :include => "albaran", :conditions => [ 'albarans.' + condicion + ' IS NOT NULL' ]
  end

  def codigo_factura_venta
    codigo = 0 
    @facturas.each do |factura|
      nuevo_codigo = /^#{ENV['TPV-FACTURA-PREFIX']}([0-9]+)$/.match(factura.codigo)
      codigo = nuevo_codigo[1].to_i if nuevo_codigo[1] && nuevo_codigo[1].to_i > codigo
    end 
    return ENV['TPV-FACTURA-PREFIX'] + format("%010d", (codigo+1).to_s)
  end

  def imprime_ticket albaran_id
    albaran = Albaran.find_by_id albaran_id
    lineas = albaran.albaran_lineas
    precio_total = 0
    subtotal = 0
    iva_total={}

    cadena =  "            ------------------------\n"
    cadena += "            | La Esquina del Zorro |\n"
    cadena += "            ------------------------\n\n"
    cadena += " C.I.F. " + ENV['TPV-CIF'] + "\n"
    cadena += " " + ENV['TPV-DIRECCION'] + "\n\n" 
    cadena += " Cliente: " + albaran.cliente.nombre + "\n"
    cadena += " Fecha: " + Time.now.strftime("%d-%m-%Y  %H:%M") + "\n"
    cadena += " Ticket: " + albaran.id.to_s + "\n\n"
    cadena += "--------------------------------------------------\n\n"
    cadena += format "Cnt.  %-31s Dto.   Imp.\n\n", "Descripcion"
    lineas.each do |linea|
      cantidad = linea.cantidad
      descuento = linea.descuento
      precio = linea.producto.precio * cantidad
      precio = precio * (1 - descuento.to_f/100)
      nombre = linea.producto.nombre
      iva = linea.producto.familia.iva.valor
      sub = precio * (1 - iva.to_f/100)
      iva_total[iva] = iva_total.key?(iva) ? iva_total[iva] + (precio-sub) : precio-sub
      subtotal += sub
      precio_total += precio
      cadena += format " %2d  %-32s  %2d  %6s\n", cantidad, nombre, descuento, format("%.2f",precio)
    end
    cadena += "\n--------------------------------------------------\n\n"
    cadena += format " %-41s %6s\n", "Subtotal", format("%.2f",subtotal)
    iva_total.each do |tipo,parcial|
      cadena += format " %-41s %6s\n", format("Iva ( %2s%% )",tipo.to_s), format("%.2f",parcial)
    end
    cadena += format "\n %-41s %6s\n\n.", "Total Euros (IVA incluido)", format("%.2f",precio_total.to_s)
    File.open("/tmp/ticket", 'w') {|f| f.write(cadena) }
    system("lpr -o cpi=20 /tmp/ticket")
  end

end
