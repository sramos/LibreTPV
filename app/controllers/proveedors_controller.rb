class ProveedorsController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Proveedores"
    redirect_to :action => :listado
  end

  def listado
    @proveedors = Proveedor.all
  end

  def editar
    @proveedor = params[:id] ?  Proveedor.find(params[:id]) : nil
    @proveedor_familia_id = params[:id] ? @proveedor.familia.id : nil
    @familias = Familia.all
  end

  def modificar
    @proveedor = params[:id] ?  Proveedor.find(params[:id]) : Proveedor.new
    @proveedor.update_attributes params[:proveedor]
    flash[:error] = @proveedor
    redirect_to :action => :listado
  end

  def borrar
    @proveedor = Proveedor.find(params[:id])
    @proveedor.destroy
    flash[:error] = @proveedor
    redirect_to :action => :listado
  end

end
