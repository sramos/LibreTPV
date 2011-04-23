class PosicionGlobalController < ApplicationController

  def index
    flash[:mensaje] = "Posicion Global."
    flash[:mensaje] << "<br>Resumen de posición global de ingresos/gastos para las fechas elegidas."
    redirect_to :action => :listado
  end

  def filtrado
    session[("tesoreria_filtrado_tipo").to_sym] = params[:filtro][:tipo] if params[:filtro]
    if params[:filtro]
      session[("tesoreria_filtrado_condicion").to_sym] = case params[:filtro][:tipo]
        when "dia"
          'YEAR(facturas.fecha) = ' + params[:filtro]["dia(1i)".to_sym] + 
		' AND MONTH(facturas.fecha) = ' + params[:filtro]["dia(2i)".to_sym] + 
		' AND DAY(facturas.fecha) = ' + params[:filtro]["dia(3i)".to_sym]
        when "mes"
          'YEAR(facturas.fecha) = ' + params[:filtro]["mes(1i)".to_sym] +
                ' AND MONTH(facturas.fecha) = ' + params[:filtro]["mes(2i)".to_sym]
        when "anno"
          'YEAR(facturas.fecha) = ' + params[:filtro]["anno(1i)".to_sym]
      end 
    else
      session[("tesoreria_filtrado_condicion").to_sym] = nil
    end
    redirect_to :action => :listado
  end

  def listado
    @campos_filtro = [["Día","dia"], ["Mes","mes"], ["Año","anno"]]
    if session[("tesoreria_filtrado_condicion").to_sym]
      @resumen = []
      importe_compra_debe=importe_compra_haber=importe_venta_debe=importe_venta_haber=importe_servicio_debe=importe_servicio_haber=0
      base_imponible_debe=base_imponible_haber=0
      factura_por_tipo("compras").each do |factura|
        importe_compra_debe += factura.debe if factura.debe
        importe_compra_haber += factura.haber if factura.haber
        base_imponible_debe += factura.base_imponible if factura.base_imponible >= 0
        base_imponible_haber += factura.base_imponible.abs if factura.base_imponible < 0
      end
      factura_por_tipo("ventas").each do |factura|
        importe_venta_debe += factura.debe if factura.debe 
        importe_venta_haber += factura.haber if factura.haber
        base_imponible_debe += factura.base_imponible if factura.base_imponible < 0
        base_imponible_haber += factura.base_imponible.abs if factura.base_imponible >= 0
      end
      factura_por_tipo("servicios").each do |factura|
        importe_servicio_debe += factura.debe if factura.debe
        importe_servicio_haber += factura.haber if factura.haber
        base_imponible_debe += factura.base_imponible if factura.base_imponible >= 0
        base_imponible_haber += factura.base_imponible.abs if factura.base_imponible < 0
      end
      total_bruto_debe = importe_compra_debe+importe_venta_debe+importe_servicio_debe
      total_bruto_haber = importe_venta_haber+importe_compra_haber+importe_servicio_haber
      iva_debe = total_bruto_debe-base_imponible_debe
      iva_haber = total_bruto_haber-base_imponible_haber
      @resumen.push([nil, ["concepto","debe","haber","total"]])
      @resumen.push(["ventas", ["Ventas",importe_venta_debe,importe_venta_haber,importe_venta_haber-importe_venta_debe]])
      @resumen.push(["compras", ["Compras de Productos",importe_compra_debe,importe_compra_haber,importe_compra_haber-importe_compra_debe]])
      @resumen.push(["servicios", ["Otros Ingresos/Gastos",importe_servicio_debe,importe_servicio_haber,importe_servicio_haber-importe_servicio_debe]])
      @resumen.push([nil, ["Total Bruto",total_bruto_debe,total_bruto_haber,total_bruto_haber-total_bruto_debe]])
      @resumen.push(["", ["","","",""]])
      @resumen.push([nil, ["Total Base Imponible",base_imponible_debe,base_imponible_haber,base_imponible_haber-base_imponible_debe]])
      @resumen.push(["", ["Iva Soportado",nil,nil,iva_debe]])
      @resumen.push(["", ["Iva Repercutido",nil,nil,iva_haber]])
      @resumen.push([nil, ["Iva a Declarar",nil,nil,iva_haber-iva_debe]])
      @resumen.push([nil, ["IRPF a declarar",0,0,0]])
      @resumen.push(["", ["","","",""]])
      @resumen.push([nil, ["Posición Global (tras impuestos)",nil,nil,base_imponible_haber+iva_debe-base_imponible_debe-iva_haber]])
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
          Factura.find :all, :order => 'facturas.fecha DESC, facturas.codigo DESC', :include => "albaran", :conditions => ["albarans.proveedor_id IS NOT NULL AND " + session[("tesoreria_filtrado_condicion").to_sym]]
        when "ventas"
          Factura.find :all, :order => 'facturas.fecha DESC, facturas.codigo DESC', :include => "albaran", :conditions => ["albarans.cliente_id IS NOT NULL AND " + session[("tesoreria_filtrado_condicion").to_sym]]
        when "servicios"
          Factura.find :all, :order => 'facturas.fecha DESC, facturas.codigo DESC', :conditions => ["facturas.albaran_id IS NULL AND " + session[("tesoreria_filtrado_condicion").to_sym]]
      end
    end
end
