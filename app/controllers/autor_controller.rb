class AutorController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Autores"
    redirect_to :action => :listado
  end

  # Obtiene el listado de autores
  def listado
    paginado = Configuracion.valor('PAGINADO')
    @autores = Autor.paginate page: params[:page], per_page: paginado, order: 'nombre'
  end

  # Prepara y presenta el formulario de edicion de un autor
  def editar
    @autor = Autor.find_by_id(params[:id]) || Autor.new 
    render :partial => "formulario"
  end

  # Actualiza o crea la informacion de un autor
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

  # Elimina la informacion de un autor
  def borrar
    @autor = Autor.find_by_id(params[:id])
    @autor.destroy
    flash[:error] = @autor
    redirect_to action: :listado, page: params[:page]
  end

  #+++
  # Acciones sobre otros elementos relacionados 
  #---

  # Sublistado de libros relacionados
  def listado_productos
    autor = Autor.find_by_id(params[:id])
    @productos = autor.producto.order("nombre")
    render :update do |page|
      page.replace_html params[:update], :partial => "productos"
    end
  end

end
