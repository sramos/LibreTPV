class PosicionGlobalController < ApplicationController

  def index
    flash[:mensaje] = "Posicion Global."
    flash[:mensaje] << "<br>Resumen de posición global de ingresos/gastos para las fechas elegidas."
    redirect_to :action => :listado
  end

  def listado
    if session[("filtrado_fecha_inicio").to_sym] && session[("filtrado_fecha_fin").to_sym]
      @resumen = []
      importe_compra_debe=importe_compra_haber=importe_venta_debe=importe_venta_haber=importe_servicio_debe=importe_servicio_haber=0
      base_imponible_debe=base_imponible_haber=0
      # IVA e IRPF debe es lo que retenemos y debemos pagar, haber es lo que nos retienen
      iva_reper=iva_sopor=irpf_reper=irpf_sopor=0
      factura_por_tipo("compras").each do |factura|
        importe_compra_debe += factura.debe if factura.debe
        importe_compra_haber += factura.haber if factura.haber
        base_imponible_debe += factura.base_imponible if factura.base_imponible >= 0
        base_imponible_haber += factura.base_imponible.abs if factura.base_imponible < 0
        iva_sopor += factura.iva_aplicado if factura.debe
        iva_reper += factura.iva_aplicado if factura.haber
      end
      factura_por_tipo("ventas").each do |factura|
        importe_venta_debe += factura.debe if factura.debe 
        importe_venta_haber += factura.haber if factura.haber
        base_imponible_debe += factura.base_imponible if factura.base_imponible < 0
        base_imponible_haber += factura.base_imponible.abs if factura.base_imponible >= 0
        iva_sopor += factura.iva_aplicado if factura.debe
        iva_reper += factura.iva_aplicado if factura.haber
      end
      factura_por_tipo("servicios").each do |factura|
        importe_servicio_debe += factura.debe if factura.debe
        importe_servicio_haber += factura.haber if factura.haber
        base_imponible_debe += factura.base_imponible if factura.base_imponible >= 0
        base_imponible_haber += factura.base_imponible.abs if factura.base_imponible < 0
        irpf_reper += factura.irpf if factura.base_imponible >= 0
        irpf_sopor += factura.irpf if factura.base_imponible <= 0
        iva_sopor += factura.iva_aplicado if factura.debe
        iva_reper += factura.iva_aplicado if factura.haber
      end
      total_bruto_debe = importe_compra_debe+importe_venta_debe+importe_servicio_debe
      total_bruto_haber = importe_venta_haber+importe_compra_haber+importe_servicio_haber
      @resumen.push([nil, ["concepto","debe","haber","total"]])
      @resumen.push(["ventas", ["Ventas",importe_venta_debe,importe_venta_haber,importe_venta_haber-importe_venta_debe]])
      @resumen.push(["compras", ["Compras de Productos",importe_compra_debe,importe_compra_haber,importe_compra_haber-importe_compra_debe]])
      @resumen.push(["servicios", ["Otros Ingresos/Gastos",importe_servicio_debe,importe_servicio_haber,importe_servicio_haber-importe_servicio_debe]])
      @resumen.push([nil, ["Total Bruto",total_bruto_debe,total_bruto_haber,total_bruto_haber-total_bruto_debe]])
      @resumen.push(["", ["","","",""]])
      @resumen.push([nil, ["Total Base Imponible",base_imponible_debe,base_imponible_haber,base_imponible_haber-base_imponible_debe]])
      @resumen.push(["", ["Iva Soportado",nil,nil,iva_sopor]])
      @resumen.push(["", ["Iva Repercutido",nil,nil,iva_reper]])
      @resumen.push([nil, ["Iva a Declarar",nil,nil,iva_reper-iva_sopor]])
      @resumen.push([nil, ["IRPF a declarar",irpf_reper,irpf_sopor,irpf_reper-irpf_sopor]])
      @resumen.push(["", ["","","",""]])
      @resumen.push([nil, ["Posición Global (tras impuestos)",nil,nil,base_imponible_haber+iva_sopor+irpf_sopor-base_imponible_debe-iva_reper-irpf_reper]])
    end
  end

  def facturas
    if params[:tipo]
      @facturas = factura_por_tipo(params[:tipo])
      render :update do |page|
        page.replace_html params[:update], :partial => "facturas"
      end
    end
  end

  private
    def factura_por_tipo tipo
      case tipo
        when "compras"
          Factura.find :all, :order => 'facturas.fecha DESC, facturas.codigo DESC', :include => "albaran", :conditions => ["albarans.proveedor_id IS NOT NULL AND facturas.fecha BETWEEN '" + session[("filtrado_fecha_inicio").to_sym].to_s + "' AND '" + session[("filtrado_fecha_fin").to_sym].to_s + "'" ]
        when "ventas"
          Factura.find :all, :order => 'facturas.fecha DESC, facturas.codigo DESC', :include => "albaran", :conditions => ["albarans.cliente_id IS NOT NULL AND facturas.fecha BETWEEN '" + session[("filtrado_fecha_inicio").to_sym].to_s + "' AND '" + session[("filtrado_fecha_fin").to_sym].to_s + "'" ]
        when "servicios"
          Factura.find :all, :order => 'facturas.fecha DESC, facturas.codigo DESC', :conditions => ["facturas.albaran_id IS NULL AND facturas.fecha AND facturas.fecha BETWEEN '" + session[("filtrado_fecha_inicio").to_sym].to_s + "' AND '" + session[("filtrado_fecha_fin").to_sym].to_s + "'" ]
      end
    end
end
