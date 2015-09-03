class AutorController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Autores"
    redirect_to :action => :listado
  end

  def listado
    paginado = Configuracion.valor('PAGINADO')
    @autores = Autor.paginate page: params[:page], per_page: paginado, order: 'nombre'
  end

  def editar
    @autor = Autor.find_by_id(params[:id]) || Autor.new 
    render :partial => "formulario"
  end

  def modificar
    @autor = Autor.find_by_id(params[:id]) || Autor.new
    if params[:renombra_autor] == "1"
      @autor.renombra_autor params[:autor][:nombre], true
    else
      @autor.update_attributes params[:autor]
    end
    flash[:error] = @autor
    redirect_to action: :listado, page: params[:page]
  end

  def borrar
    @autor = Autor.find_by_id(params[:id])
    @autor.destroy
    flash[:error] = @autor
    redirect_to action: :listado, page: params[:page]
  end

end
