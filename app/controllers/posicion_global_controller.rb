class PosicionGlobalController < ApplicationController

  def index
    redirect_to :action => :listado
  end

  def listado
    if cookies[("filtrado_fecha_inicio").to_sym] && cookies[("filtrado_fecha_fin").to_sym]
      @resumen = []
      importe_compra_debe=importe_compra_haber=importe_venta_debe=importe_venta_haber=importe_servicio_debe=importe_servicio_haber=0
      base_imponible_debe=base_imponible_haber=0
      desglose_por_iva_sopor = Hash.new
      desglose_por_iva_reper = Hash.new
      # IVA e IRPF debe es lo que retenemos y debemos pagar, haber es lo que nos retienen
      iva_reper=iva_sopor=irpf_reper=irpf_sopor=0
      factura_por_tipo("compras").each do |factura|
        importe_compra_debe += factura.importe
        base_imponible_debe += factura.base_imponible
        iva_sopor += factura.iva_aplicado
        desglose = factura.desglose_por_iva
        desglose.each_key do |k|
          desglose_por_iva_sopor[k] = [0,0,0] if desglose_por_iva_sopor[k].nil?
          desglose_por_iva_sopor[k][0] += desglose[k][0] 
          desglose_por_iva_sopor[k][1] += desglose[k][1]
          desglose_por_iva_sopor[k][2] += desglose[k][2]
        end
      end
      factura_por_tipo("ventas").each do |factura|
        importe_venta_haber += factura.importe
        base_imponible_haber += factura.base_imponible
        iva_reper += factura.iva_aplicado
        desglose = factura.desglose_por_iva
        desglose.each_key do |k|
          desglose_por_iva_reper[k] = [0,0,0] if desglose_por_iva_reper[k].nil?
          desglose_por_iva_reper[k][0] += desglose[k][0]
          desglose_por_iva_reper[k][1] += desglose[k][1]
          desglose_por_iva_reper[k][2] += desglose[k][2]
        end
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
        desglose = factura.desglose_por_iva
        desglose.each_key do |k|
          if factura.debe
            desglose_por_iva_sopor[k] = [0,0,0] if desglose_por_iva_sopor[k].nil?
            desglose_por_iva_sopor[k][0] += desglose[k][0]
            desglose_por_iva_sopor[k][1] += desglose[k][1]
            desglose_por_iva_sopor[k][2] += desglose[k][2]
          else
            desglose_por_iva_reper[k] = [0,0,0] if desglose_por_iva_reper[k].nil?
            desglose_por_iva_reper[k][0] += desglose[k][0]
            desglose_por_iva_reper[k][1] += desglose[k][1]
            desglose_por_iva_reper[k][2] += desglose[k][2]
          end
        end
      end
      total_bruto_debe = importe_compra_debe+importe_venta_debe+importe_servicio_debe
      total_bruto_haber = importe_venta_haber+importe_compra_haber+importe_servicio_haber
      @resumen.push([nil, ["concepto","debe","haber","total"],"nuevo"])
      @resumen.push(["ventas", ["Ventas",importe_venta_debe,importe_venta_haber,importe_venta_haber-importe_venta_debe]])
      @resumen.push(["compras", ["Compras de Productos",importe_compra_debe,importe_compra_haber,importe_compra_haber-importe_compra_debe]])
      @resumen.push(["servicios", ["Otros Ingresos/Gastos",importe_servicio_debe,importe_servicio_haber,importe_servicio_haber-importe_servicio_debe]])
      @resumen.push([nil, ["Total Bruto",total_bruto_debe,total_bruto_haber,total_bruto_haber-total_bruto_debe]])
      @resumen.push([nil, ["Total Base Imponible",base_imponible_debe,base_imponible_haber,base_imponible_haber-base_imponible_debe]])
      @resumen.push([nil, ["IVA a declarar",iva_reper,iva_sopor,iva_reper-iva_sopor]])
      @resumen.push([nil, ["IRPF a declarar",irpf_reper,irpf_sopor,irpf_reper-irpf_sopor]])
      @resumen.push(["", ["","","",""]])
      @resumen.push([nil, ["Posición Global (tras impuestos)",nil,nil,base_imponible_haber+iva_sopor+irpf_sopor-base_imponible_debe-iva_reper-irpf_reper]])
      @resumen.push(["", ["","","",""]])

      @resumen.push([nil, ["iva soportado","base_imponible_por_iva","total_iva","importe_total"], "nuevo"])
      desglose_por_iva_sopor.each_key do |k|
        @resumen.push(["", [k.to_s + " %",desglose_por_iva_sopor[k][0],desglose_por_iva_sopor[k][1],desglose_por_iva_sopor[k][2]] ])
      end
      @resumen.push([nil, ["iva repercutido","base_imponible_por_iva","total_iva","importe_total"], "nuevo"])
      desglose_por_iva_reper.each_key do |k|
        @resumen.push(["", [k.to_s + " %",desglose_por_iva_reper[k][0],desglose_por_iva_reper[k][1],desglose_por_iva_reper[k][2]] ])
      end
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
      filtro_fecha = "facturas.fecha BETWEEN '" + cookies[("filtrado_fecha_inicio").to_sym].to_s + "' AND '" + cookies[("filtrado_fecha_fin").to_sym].to_s + "'"
      case tipo
        when "compras"
          Factura.find :all, :order => 'facturas.fecha DESC, facturas.codigo DESC', :include => ["albarans"], :conditions => ["albarans.proveedor_id IS NOT NULL AND " + filtro_fecha]
        when "ventas"
          Factura.find :all, :order => 'facturas.fecha DESC, facturas.codigo DESC', :include => ["albarans"], :conditions => ["albarans.cliente_id IS NOT NULL AND " + filtro_fecha ]
        when "servicios"
          Factura.find :all, :order => 'facturas.fecha DESC, facturas.codigo DESC', :conditions => ["facturas.proveedor_id IS NOT NULL AND facturas.fecha AND " + filtro_fecha ]
      end
    end
end
