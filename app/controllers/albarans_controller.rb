class AlbaransController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Albaranes de Proveedores" if :seccion == "proveedores"
    flash[:mensaje] = "Listado de Albaranes de Clientes" if :seccion == "clientes"
    redirect_to :action => :listado
  end

  def listado
    @albarans = Albaran.all
  end

  def editar
    if params[:id]
      @albaran = Albaran.find(params[:id])
      @albaran_lineas = @albaran.albaran_lineas
      params[:update] = 'lineas_albaran'
      params[:albaran_id] = @albaran.id
      render :action => :modificar
    else
      @proveedores = Proveedor.all
    end
  end

  def modificar
    @albaran = params[:id] ? Albaran.find(params[:id]) : Albaran.new
    @albaran.update_attributes params[:albaran]
    flash[:error] = @albaran
    redirect_to :action => :editar, :id => @albaran.id
  end

  def modificar_viejo
    @albaran = params[:id] ?  Albaran.find(params[:id]) : Albaran.new
    @albaran.update_attributes params[:albaran]
    flash[:error] = @albaran
    redirect_to :action => :listado
  end

  def borrar
    @albaran = Albaran.find(params[:id])
    @albaran.destroy
    flash[:error] = @albaran
    redirect_to :action => :listado
  end

end
