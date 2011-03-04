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
    @productos = Producto.all
  end

  def modificar
    @albaranlinea = params[:id] ?  AlbaranLinea.find(params[:id]) : AlbaranLinea.new
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


  # Lineas de Albaran => Asignaciones

  def lineas
    albaran = Albaran.find(params[:albaran_id])
    @albaran_lineas = albaran.albaran_lineas 
    render :update do |page|
      page.replace_html params[:update], :partial => "lineas"
    end    
  end

  def editar_linea
    @albaranlinea = params[:id] ?  AlbaranLinea.find(params[:id]) : AlbaranLinea.new
    @albaran = Albaran.find(params[:albaran_id])
    render :update do |page|
      page.replace_html params[:update] + "_linea_editar", :partial => "editar_linea"
    end
  end

  def asignar_linea
    params[:albaranlinea][:producto_id] = params[:producto][:id]
    albaranlinea = params[:id] ? AlbaranLinea.find(params[:id]) : AlbaranLinea.new
    albaranlinea.update_attributes params[:albaranlinea]
    #flash[:error] = albaranlinea
    #@albaran_lineas = Albaran.find(albaranlinea.albaran_id).albaran_lineas
    #redirect_to :action => :lineas, :albaran_id => albaranlinea.albaran_id, :update => params[:update]
    #render :update do |page|
    #  page.replace_html params[:update], :partial => "lineas"
    #end
    redirect_to :controller => :albarans, :action => :editar, :id => albaranlinea.albaran_id
  end

  def eliminar_linea
    albaranlinea = AlbaranLinea.find_by_id params[:id] 
    if albaranlinea 
      albaranlinea.destroy
      #flash[:error] = albaranlinea
      #@albaran_lineas = Albaran.find(params[:albaran_id]).albaran_lineas
      #render :update do |page|
      #  page.replace_html params[:update], :partial => "lineas"
      #end
    #else
    #  render :nothing => true
    end
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

end
