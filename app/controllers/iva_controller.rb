class IvaController < ApplicationController

  def index
    flash[:mensaje] = "Listado de tipos de IVA"
    redirect_to :action => :listado
  end

  def listado
    @ivas = Iva.all
  end

  def editar
    @iva = params[:id] ?  Iva.find(params[:id]) : nil
    render :partial => "formulario"
  end

  def modificar 
    @iva = params[:id] ?  Iva.find(params[:id]) : Iva.new
    @iva.update_attributes params[:iva]
    flash[:error] = @iva
    redirect_to :action => :listado
  end
  
  def borrar 
    @iva = Iva.find(params[:id])
    @iva.destroy
    flash[:error] = @iva
    redirect_to :action => :listado
  end

end
