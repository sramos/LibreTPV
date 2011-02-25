class CamposController < ApplicationController

  def index
    flash[:mensaje] = "Listado de posibles campos de productos"
    redirect_to :action => :listado
  end

  def listado
    @campos = Campo.all
  end

  def editar
    @campo = params[:id] ?  Campo.find(params[:id]) : nil
  end

  def modificar 
    @campo = params[:id] ?  Campo.find(params[:id]) : Campo.new
    @campo.update_attributes params[:campo]
    flash[:error] = @campo
    redirect_to :action => :listado
  end
  
  def borrar 
    @campo = Campo.find(params[:id])
    @campo.destroy
    flash[:error] = @campo
    redirect_to :action => :listado
  end

  # Lista los campos de una familia
  def listar_campos
    @familia = Familia.find(params[:id])
    @campos = @familia.campo
    render :update do |page|
      page.replace_html params[:update], :partial => "campos"
    end
  end


end
