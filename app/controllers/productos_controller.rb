class ProductosController < ApplicationController

  def index
    flash[:mensaje] = ("Listado de productos")
    redirect_to :action => 'listado'
  end

  def listado 
    @productos = Productos.all
  end

end
