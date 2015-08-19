class EditorialController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Editoriales"
    redirect_to :action => :listado
  end

  def listado
    @editoriales = Editorial.all(:order => 'nombre')
  end

  def editar
    @editorial = Editorial.find_by_id(params[:id]) || Editorial.new 
    render :partial => "formulario"
  end

  def modificar
    @editorial = Editorial.find_by_id(params[:id]) || Editorial.new
    @editorial.update_attributes params[:editorial]
    flash[:error] = @editorial
    redirect_to :action => :listado
  end

  def borrar
    @editorial = Editorial.find_by_id(params[:id])
    @editorial.destroy
    flash[:error] = @editorial
    redirect_to :action => :listado
  end

end
