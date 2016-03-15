class InformeController < ApplicationController

  require 'spreadsheet'

  def index
    flash[:mensaje] = "Listado de elementos 'Perdidos'"
    redirect_to :action => 'listado'
  end

  def listado
    @informes = [	["Stock de Productos", "stock_productos"],
			["Productos Vendidos por Fecha", "productos_vendidos"], 
			["Productos Vendidos (Resumen)", "productos_vendidos_resumen"],
                        ["Productos Recibidos por Fecha", "productos_recibidos"],
			["Productos Recibidos (Resumen)", "productos_recibidos_resumen"],
                        ["Facturas de Venta", "facturas_venta"],
                        ["Facturas de Compra", "facturas_compra"],
                        ["Facturas de Otros Gastos", "facturas_servicios"],
                 ]

    if params[:informe]
      #fecha_inicio = Date.civil(params[:informe][:"fecha_inicio(1i)"].to_i,params[:informe][:"fecha_inicio(2i)"].to_i,params[:informe][:"fecha_inicio(3i)"].to_i)
      #fecha_fin = Date.civil(params[:informe][:"fecha_fin(1i)"].to_i,params[:informe][:"fecha_fin(2i)"].to_i,params[:informe][:"fecha_fin(3i)"].to_i)
      fecha_inicio = Date.strptime(params[:informe][:fecha_inicio], "%d/%m/%Y") unless params[:informe][:fecha_inicio].blank
      fecha_fin = Date.strptime(params[:informe][:fecha_fin], "%d/%m/%Y") unless params[:informe][:fecha_fin].blank
      if params[:informe][:tipo] == "stock_productos" || (fecha_inicio && fecha_fin && fecha_fin > fecha_inicio)
        informe = send "#{params[:informe][:tipo]}", fecha_inicio, fecha_fin
        if informe
          tempfile = Tempfile.new("informe.xls")
          informe.write(tempfile.path)
          send_file tempfile.path, :filename => 'Informe.xls', :type => 'application/vnd.ms-excel' 
        else
          flash[:error] = "Informe no disponible"
        end
      else
        flash[:error] = "La fecha de inicio debe ser mayor que la fecha de fin del informe." unless fecha_fin > fecha_inicio 
      end
    end
  end

  # Stock de Productos
  def stock_productos fecha_inicio, fecha_fin
    campos = [	["Cantidad", "cantidad"], ["Codigo", "codigo"], ["Nombre", "nombre"] ]
    objetos = Producto.find :all, :order => [ "nombre ASC" ], :conditions => [ "cantidad > 0" ]
    return genera_informe(objetos,campos)
  end

  # Resumen de ventas por productos y fecha
  def productos_vendidos fecha_inicio, fecha_fin
    campos = [	["Fecha", "albaran.factura.fecha"], ["Producto", "nombre_producto"], ["Cliente", "albaran.cliente.nombre"],
		["Cantidad", "cantidad"], ["PVP", "precio_venta", true], ["% Descuento", "descuento"], ["Base Imponible", "subtotal", true], ["% IVA", "iva"], ["Total", "total", true] ]
    objetos = []
    condicion = [ "cliente_id IS NOT NULL AND facturas.fecha BETWEEN '" + fecha_inicio.to_s + "' AND '" + fecha_fin.to_s + "'" ]
    Albaran.find(:all, :order => 'facturas.fecha DESC', :include => "factura", :conditions => condicion).each do |albaran|
      objetos += albaran.albaran_lineas
    end
    return genera_informe(objetos,campos)
  end

  # Resumen de ventas por productos
  def productos_vendidos_resumen fecha_inicio, fecha_fin
    campos = [  ["Cantidad", "cantidad"], ["Codigo", "codigo"], ["Producto", "nombre_producto"] ]
    productos = {}
    condicion = condicion = "cliente_id IS NOT NULL"
    condicion += " AND facturas.fecha BETWEEN '" + fecha_inicio.to_s + "' AND '" + fecha_fin.to_s + "'"
    Albaran.find(:all, :include => "factura", :conditions => condicion).each do |albaran|
      albaran.albaran_lineas.each do |linea|
        if productos[linea.producto_id]
          productos[linea.producto_id]['cantidad'] += linea.cantidad
        else
          productos[linea.producto_id] = {'nombre_producto' => linea.nombre_producto, 'cantidad' => linea.cantidad }
          productos[linea.producto_id]['codigo'] = linea.producto.codigo if linea.producto
        end 
      end
    end
    objetos=productos.each_value 
    tempfile = Tempfile.new("informe.xls")
    return genera_informe(objetos,campos)
  end

  def productos_recibidos fecha_inicio, fecha_fin
    campos = [  ["Fecha", "albaran.fecha"], ["Producto", "nombre_producto"], ["PVP", "producto.precio", true], ["Proveedor", "albaran.proveedor.nombre"],
                ["Cantidad", "cantidad"], ["P.Dist.", "precio_compra", true], ["% Descuento", "descuento"], ["Base Imponible", "subtotal", true], ["% IVA", "iva"], ["Total", "total", true] ]
    condicion  = "albarans.proveedor_id IS NOT NULL AND albarans.cerrado"
    condicion += " AND albarans.fecha BETWEEN '" + fecha_inicio.to_s + "' AND '" + fecha_fin.to_s + "'"
    objetos = AlbaranLinea.find(:all, :order => 'albarans.fecha DESC', :include => 'albaran', :conditions => [ condicion ])
    return genera_informe(objetos,campos)
  end

  def productos_recibidos_resumen fecha_inicio, fecha_fin
    campos = [  ["Cantidad", "cantidad"], ["Codigo", "codigo"], ["Producto", "nombre_producto"] ]
    productos = {}
    condicion  = "albarans.proveedor_id IS NOT NULL AND albarans.cerrado"
    condicion += " AND albarans.fecha BETWEEN '" + fecha_inicio.to_s + "' AND '" + fecha_fin.to_s + "'"
    AlbaranLinea.find(:all, :include => 'albaran', :conditions => [ condicion ]).each do |linea|
      if productos[linea.producto_id]
        productos[linea.producto_id]['cantidad'] += linea.cantidad
      else
        productos[linea.producto_id]={'nombre_producto' => linea.nombre_producto, 'cantidad' => linea.cantidad }
        productos[linea.producto_id]['codigo'] = linea.producto.codigo if linea.producto
      end
    end
    objetos=productos.each_value
    return genera_informe(objetos,campos)
  end

  def facturas_venta fecha_inicio, fecha_fin
    campos = [  ["Fecha", "fecha"], ["Codigo", "codigo"], ["Cliente", "albaran.cliente.nombre"],
                ["Base Imponible", "base_imponible", true], ["IVA", "iva_aplicado", true], ["Total", "importe", true] ]
    condicion = "albarans.cliente_id IS NOT NULL AND facturas.fecha BETWEEN '" + fecha_inicio.to_s + "' AND '" + fecha_fin.to_s + "'"
    objetos = Factura.find(:all, :order => 'facturas.fecha DESC', :include => 'albaran', :conditions => [ condicion ])
    return genera_informe(objetos,campos)
  end

  def facturas_compra fecha_inicio, fecha_fin
    campos = [	["Fecha", "fecha"], ["Codigo", "codigo"], ["Proveedor", "albaran.proveedor.nombre"],
		["Base Imponible", "base_imponible", true], ["IVA", "iva_aplicado", true], ["Total", "importe", true] ]
    condicion = "albarans.proveedor_id IS NOT NULL AND facturas.fecha BETWEEN '" + fecha_inicio.to_s + "' AND '" + fecha_fin.to_s + "'"
    objetos = Factura.find(:all, :order => 'facturas.fecha DESC', :include => 'albaran', :conditions => [ condicion ])
    return genera_informe(objetos,campos)
  end

  def facturas_servicios fecha_inicio, fecha_fin
    campos = [  ["Fecha", "fecha"], ["Codigo", "codigo"], ["Proveedor", "proveedor.nombre"],
		["Base Imponible", "base_imponible", true], ["IVA", "iva_aplicado", true], ["IRPF", "irpf"], ["Total", "importe", true] ] 
    condicion = "albaran_id IS NULL AND facturas.fecha BETWEEN '" + fecha_inicio.to_s + "' AND '" + fecha_fin.to_s + "'"
    objetos = Factura.find(:all, :order => 'facturas.fecha DESC', :include => 'albaran', :conditions => [ condicion ])
    return genera_informe(objetos,campos)
  end

  private
    def genera_informe objetos, campos
      libro = Spreadsheet::Workbook.new
      fmt_numero = Spreadsheet::Format.new :number_format => '0.00'
      #fmt_color = Spreadsheet::Format.new :pattern => 1, :pattern_fg_color => :aqua
      nombre = "Informe/Resumen"
      hoja = libro.create_worksheet :name => nombre 
      # Genera la cabecera de la hoja
      campos.each_index do |indice|
        hoja[0,indice] = campos[indice][0]
      end
      hoja.row(0).default_format = Spreadsheet::Format.new :weight => :bold
      # Va metiendo los datos de cada objeto
      color = true
      num_linea = 1
      objetos.each do |objeto|
        #hoja.row(num_linea).default_format = fmt_color if color
        campos.each do |campo|
          contenido = objeto
          campo[1].split('.').each { |metodo| contenido = contenido.send(metodo) if contenido } unless objeto.class.name == "Hash"
          campo[1].split('.').each { |metodo| contenido = contenido[metodo] if contenido } if objeto.class.name == "Hash"
          hoja[num_linea, campos.index(campo)] = contenido
          hoja.row(num_linea).set_format(campos.index(campo),fmt_numero) if campo[2]
        end
        color = !color
        num_linea += 1
      end
      return libro
    end
end
