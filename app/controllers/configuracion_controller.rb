class ConfiguracionController < ApplicationController

  def index
    flash[:mensaje] = "Parametros de Configuracion"
    redirect_to :action => :listado
  end

  def listado
    @config = Configuracion.all
  end

  def editar
    @config = Configuracion.find(params[:id])
    render :partial => "formulario"
  end

  def modificar 
    @config = Configuracion.find(params[:id])
    @config.update_attributes params[:config] if @config.editable
    flash[:error] = @config
    redirect_to :action => :listado
  end
  
end
