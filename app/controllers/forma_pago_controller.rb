class FormaPagoController < ApplicationController
  def index
    flash[:mensaje] = "Listado de Formas de Pago"
    redirect_to :action => :listado
  end

  def listado
    @formasdepago = FormaPago.all
  end

  def editar
    @formadepago = params[:id] ?  FormaPago.find(params[:id]) : nil
    render :partial => "formulario"
  end

  def modificar
    @formadepago = params[:id] ?  FormaPago.find(params[:id]) : FormaPago.new
    @formadepago.update_attributes params[:formadepago]
    flash[:error] = @formadepago
    redirect_to :action => :listado
  end

  def borrar
    @formadepago = FormaPago.find(params[:id])
    @formadepago.destroy
    flash[:error] = @formadepago
    redirect_to :action => :listado
  end
end
