class EditorialController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Editoriales"
    redirect_to :action => :listado
  end

  def filtrado
    session[("editorial_filtrado_tipo").to_sym] = params[:filtro][:tipo] if params[:filtro]
    session[("editorial_filtrado_valor").to_sym] = ( params[:filtro] && params[:filtro][:valor] != "" ) ? params[:filtro][:valor] : nil
    session[("editorial_filtrado_condicion").to_sym] = params[:filtro] ? params[:filtro][:condicion] : nil
    redirect_to :action => :listado
  end

  def listado
    @campos_filtro = [["Nombre","nombre"]]
    paginado = Configuracion.valor('PAGINADO')

    if session[("editorial_filtrado_tipo").to_sym] && session[("editorial_filtrado_valor").to_sym]
      @editoriales = Editorial.where('nombre LIKE ?', "%" + session[("editorial_filtrado_valor").to_sym] + "%").
                               order("nombre ASC").
                               paginate(page: params[:page], per_page: paginado) if session[("editorial_filtrado_tipo").to_sym] == "nombre"
    else
      @editoriales = Editorial.order(:nombre).paginate(page: params[:page], pero_page: paginado)
    end
  end

  def editar
    @editorial = Editorial.find_by_id(params[:id]) || Editorial.new
    render :partial => "formulario"
  end

  def modificar
    @editorial = Editorial.find_by_id(params[:id]) || Editorial.new
    if @editorial.id && params[:renombra_editorial] == "1"
      @editorial.renombra params[:editorial][:nombre], true
    else
      @editorial.update_attributes params[:editorial]
    end
    flash[:error] = @editorial
    redirect_to :action => :listado
  end

  def borrar
    @editorial = Editorial.find_by_id(params[:id])
    @editorial.destroy
    flash[:error] = @editorial.errors.full_messages.join(" ")
    redirect_to :action => :listado
  end

end
