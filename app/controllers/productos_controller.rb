class ProductosController < ApplicationController

  def index
    @productos = Productos.all
  end

end
