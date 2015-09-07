class MateriaController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Materias"
    redirect_to :action => :listado
  end

  def listado
    @materias = Materia.all(:order => 'nombre')
  end

  def editar
    @materia = Materia.find_by_id(params[:id]) || Materia.new 
    @familias = Familia.order(:nombre)
    render :partial => "formulario"
  end

  def modificar
    @materia = Materia.find_by_id(params[:id]) || Materia.new
    @materia.update_attributes params[:materia]
    flash[:error] = @materia
    redirect_to :action => :listado
  end

  def borrar
    @materia = Materia.find_by_id(params[:id])
    @materia.destroy
    flash[:error] = @materia
    redirect_to :action => :listado
  end

end
