class PagoController < ApplicationController

  # --
  # METODOS AJAX DE PAGOS
  # --

  def pagos
    @pagos = Factura.find(params[:factura_id]).pagos
    render :update do |page|
      page.replace_html params[:update], :partial => "listado"
    end
  end

  def nuevo_pago
    @pago = params[:id] ?  Pago.find(params[:id]) : Pago.new
    factura = Factura.find_by_id params[:factura_id]
    @pago.factura = factura 
    pagopendiente = factura.importe
    factura.pagos.each { |pago| pagopendiente -= pago.importe }
    pagofecha = Time.now.to_s
    render :partial => "formulario", :update => params[:update], :locals => {:pagopendiente => pagopendiente.to_s}
  end

  def modificar_pago
    @pago = params[:id] ? Pago.find(params[:id]) : Pago.new
    @pago.update_attributes params[:pago]
    @pagos = Factura.find(@pago.factura_id).pagos
    render :update do |page|
      page.replace_html params[:update], :partial => "listado"
      page.visual_effect :highlight, params[:update] , :duration => 6
      page.replace 'formulario', :inline => '<%= mensaje_error(@pago) %><br>'
      page.call("Modalbox.resizeToContent")
    end
  end

  def eliminar_pago
    pago = Pago.find(params[:id])
    pago.destroy
    @pagos = Factura.find(params[:factura_id]).pago
    render :update do |page|
      page.replace_html params[:update], :partial => "listado"
      page.visual_effect :highlight, params[:update] , :duration => 6
      page.replace_html 'MB_content', :inline => '<%= mensaje_error(pago, :eliminar => true) %><br>'
      page.call("Modalbox.resizeToContent")
    end
  end

end
