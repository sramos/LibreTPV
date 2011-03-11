class ClientesController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Clientes"
    redirect_to :action => :listado
  end

  def listado
    @clientes = Cliente.all
  end

  def editar
    @cliente = params[:id] ? Cliente.find(params[:id]) : Cliente.new
    render :partial => "formulario"
  end

  def modificar
    cliente = params[:id] ? Cliente.find(params[:id]) : Cliente.new
    cliente.update_attributes params[:cliente]
    flash[:error] = cliente
    redirect_to :action => :listado
  end

  def borrar
    cliente = Cliente.find_by_id params[:id]
    cliente.destroy
    flash[:error] = cliente 
    redirect_to :action => :listado
  end

end
