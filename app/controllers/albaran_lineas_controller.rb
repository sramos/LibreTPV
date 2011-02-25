class AlbaranLineasController < ApplicationController


  def index
    flash[:mensaje] = "Listado de Lineas de Albaran"
    redirect_to :action => :listado
  end

  def listado
    @albaran_lineas = AlbaranLinea.all
  end

  def editar
    @albaranlinea = params[:id] ?  AlbaranLinea.find(params[:id]) : nil
  end

  def modificar
    @albaranlinea = params[:id] ?  AlbaranLinea.find(params[:id]) : AlbaLinea.new
    @albaranlinea.update_attributes params[:albaranlinea]
    flash[:error] = @albaranlinea
    redirect_to :action => :listado
  end

  def borrar
    @albaranlinea = AlbaranLinea.find(params[:id])
    @albaranlinea.destroy
    flash[:error] = @albaranlinea
    redirect_to :action => :listado
  end

  def lineas
    @albaran = Albaran.find(params[:albaran_id])
    @albaran_lineas = @albaran.albaran_lineas 
    render :update do |page|
      page.replace_html params[:update], :partial => "lineas", :local => { :albaran_id => params[:albaran_id]}
    end    
  end

end
