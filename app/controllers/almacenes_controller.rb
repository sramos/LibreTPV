class AlmacenesController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Almacenes"
    redirect_to :action => :listado
  end

  def listado
    @almacenes = Almacen.order(:nombre)
  end

  def editar
    @almacen = Almacen.find_by_id(params[:id]) || Almacen.new
    render :partial => "formulario"
  end

  def modificar
    @almacen = Almacen.find_by_id(params[:id]) || Almacen.new
    @almacen.update_attributes params[:almacen]
    flash[:error] = @almacen
    redirect_to :action => :listado
  end

  def borrar
    @almacen = Almacen.find_by_id(params[:id])
    @almacen.destroy if @almacen
    flash[:error] = @almacen
    redirect_to :action => :listado
  end

end
