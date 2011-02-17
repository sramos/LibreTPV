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
    @albaran = params[:id] ?  Albaran.find(params[:id]) : nil
  end

  def modificar
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
