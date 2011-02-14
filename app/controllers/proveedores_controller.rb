class ProveedoresController < ApplicationController

  def index
    flash[:mensaje] = ("Listado de proveedores")
    redirect_to :action => 'listado'
  end

  def listado
    @proveedores = Proveedores.all
  end

end
