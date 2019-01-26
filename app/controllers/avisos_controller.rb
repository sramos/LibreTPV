class AvisosController < ApplicationController

  def index
    flash[:mensaje] = "Avisos"
    redirect_to :action => :listado
  end

  def listado
    @avisos = Avisos.order("criticidad desc, updated_at asc").
                     paginate(page: (params[:format]=='xls' ? nil : params[:page]),
                              per_page: (params[:format_xls_count] || Configuracion.valor('PAGINADO') )
  end

  def editar
    @aviso = params[:id] ?  Avisos.find(params[:id]) : Avisos.new
    render :partial => "formulario"
  end

  def modificar
    @aviso = params[:id] ?  Avisos.find(params[:id]) : Avisos.new
    @aviso.update_attributes params[:aviso]
    flash[:error] = @aviso
    redirect_to :action => :listado
  end

  def borrar
    @aviso = Avisos.find(params[:id])
    @aviso.destroy
    flash[:error] = @aviso
    redirect_to :action => :listado
  end

end
