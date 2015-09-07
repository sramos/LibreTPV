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
      @editoriales = case session[("editorial_filtrado_tipo").to_sym]
        when "nombre" then
          Editorial.paginate :page => params[:page], :per_page => paginado,
                :order => 'nombre ASC',
                :conditions => [ session[("editorial_filtrado_tipo").to_sym] + ' LIKE ?', "%" + session[("editorial_filtrado_valor").to_sym] + "%" ]
        end
    else
      @editoriales = Editorial.paginate :page => params[:page], :per_page => paginado, :order => 'nombre'
    end
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
