class ProductosController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Productos"
    redirect_to :action => :listado
  end

  def listado
    @productos = Producto.all
  end

  def editar
    @producto = params[:id] ?  Producto.find(params[:id]) : nil
    @familias = Familia.all
  end

  def modificar
    @producto = params[:id] ?  Producto.find(params[:id]) : Producto.new
    @producto.update_attributes params[:producto]
    flash[:error] = @producto
    redirect_to :action => :listado
  end

  def borrar
    @producto = Producto.find(params[:id])
    @producto.destroy
    flash[:error] = @producto
    redirect_to :action => :listado
  end

end
