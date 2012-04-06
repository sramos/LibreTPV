class PagoController < ApplicationController

  # --
  # METODOS AJAX DE PAGOS
  # --

  def pagos
    @factura = Factura.find(params[:factura_id])
    @pagos = @factura.pagos
    render :update do |page|
      page.replace_html params[:update], :partial => "listado"
    end
  end

  def nuevo_pago
    @pago = params[:id] ?  Pago.find(params[:id]) : Pago.new
    @formasdepago = FormaPago.all
    factura = Factura.find_by_id params[:factura_id]
    @pago.factura = factura 
    @pago_pendiente = factura.pago_pendiente
    pagofecha = Time.now.to_s
    render :partial => "formulario", :update => params[:update]
  end

  def modificar_pago
    @pago = params[:id] ? Pago.find(params[:id]) : Pago.new
    @pago.forma_pago_id = params[:forma_pago][:id]
    @pago.update_attributes params[:pago]
    # Si el pago es de hoy, incluimos hora/minutos/segundos para poder filtrar luego en arqueo
    if (@pago.fecha == Date.current)
      @pago.fecha += Time.current.hour.hours + Time.current.min.minutes + Time.current.sec.seconds
      @pago.save
    end
    @factura = Factura.find(@pago.factura_id)
    @pagos = @factura.pagos
    if @factura.pago_pendiente == 0 && !@factura.pagado
      @factura.pagado = true
      @factura.save
    end
    render :update do |page|
      page.replace_html params[:update], :partial => "listado"
      page.visual_effect :highlight, params[:update] , :duration => 6
      page.replace 'formulario_ajax', :inline => '<%= mensaje_error(@pago) %><br>'
      page.hide 'factura_' + @factura.id.to_s + '_aviso_pago' if @factura.pagado
      page.call("Modalbox.resizeToContent")
    end
  end

  def eliminar_pago
    @pago = Pago.find(params[:id])
    @pago.destroy
    @factura = Factura.find(params[:factura_id])
    @pagos = @factura.pagos
    if @factura.pago_pendiente != 0 && @factura.pagado
      @factura.pagado = false 
      @factura.save
    end
    render :update do |page|
      page.replace_html params[:update], :partial => "listado"
      page.visual_effect :highlight, params[:update] , :duration => 6
      page.show 'factura_' + @factura.id.to_s + '_aviso_pago' unless @factura.pagado
      page.replace_html 'MB_content', :inline => '<%= mensaje_error(@pago, :eliminar => true) %><br>'
      page.call("Modalbox.resizeToContent")
    end
  end

private
  def pago_pendiente
    factura = Factura.find(params[:factura_id])
    @pagos = factura.pagos
    @pago_pendiente = factura.pago_pendiente
  end
end
