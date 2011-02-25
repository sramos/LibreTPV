class FamiliasController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Familias"
    redirect_to :action => :listado
  end

  def listado
    @familias = Familia.all
  end

  def editar
    @familia = params[:id] ?  Familia.find(params[:id]) : nil
    @ivas = Iva.all
  end

  def modificar
    @familia = params[:id] ?  Familia.find(params[:id]) : Familia.new
    @familia.update_attributes params[:familia]
    flash[:error] = @familia
    redirect_to :action => :listado
  end

  def borrar
    @familia = Familia.find(params[:id])
    @familia.destroy
    flash[:error] = @familia
    redirect_to :action => :listado
  end

  def listar_familias
    @familia = params[:id] ?  Familia.find(params[:id]) : nil
    @campos = @familia.campo  
    render :update do |page|
      page.replace_html params[:update], :partial => "campos"
    end
  end

end
