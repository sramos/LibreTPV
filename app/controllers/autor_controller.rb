class AutorController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Autores"
    redirect_to :action => :listado
  end

  def filtrado
    session[("autores_filtrado_tipo").to_sym] = params[:filtro][:tipo] if params[:filtro]
    session[("autores_filtrado_valor").to_sym] = ( params[:filtro] && params[:filtro][:valor] != "" ) ? params[:filtro][:valor] : nil
    session[("autores_filtrado_condicion").to_sym] = params[:filtro] ? params[:filtro][:condicion] : nil 
    redirect_to :action => :listado
  end

  # Obtiene el listado de autores
  def listado
    @campos_filtro = [["Nombre","nombre"]]
    paginado = Configuracion.valor('PAGINADO')

    if session[("autores_filtrado_tipo").to_sym] && session[("autores_filtrado_valor").to_sym]
      @autores = case session[("autores_filtrado_tipo").to_sym]
        when "nombre" then
          Autor.paginate :page => params[:page], :per_page => paginado,
                :order => 'nombre ASC',
                :conditions => [ session[("autores_filtrado_tipo").to_sym] + ' LIKE ?', "%" + session[("autores_filtrado_valor").to_sym] + "%" ]
        end
    else
      @autores = Autor.paginate page: params[:page], per_page: paginado, order: 'nombre'
    end
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
