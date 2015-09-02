class AutorController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Autores"
    redirect_to :action => :listado
  end

  def listado
    paginado = Configuracion.valor('PAGINADO')
    @autores = Autor.paginate :page => params[:page], :per_page => paginado, :order => 'nombre'
  end

  def editar
    @autor = Autor.find_by_id(params[:id]) || Autor.new 
    render :partial => "formulario"
  end

  def modificar
    @autor = Autor.find_by_id(params[:id]) || Autor.new
    @autor.update_attributes params[:autor]
    flash[:error] = @autor
    redirect_to :action => :listado
  end

  def borrar
    @autor = Autor.find_by_id(params[:id])
    @autor.destroy
    flash[:error] = @autor
    redirect_to :action => :listado
  end

end
