class AlbaranLineasController < ApplicationController


  # Metodos AJAX de Lineas de Albaran

  def lineas
    albaran = Albaran.find(params[:albaran_id])
    @albaran_lineas = albaran.albaran_lineas 
    render :update do |page|
      page.replace_html params[:update], :partial => "lineas"
    end    
  end

  def asignar_linea
    albaran = Albaran.find_by_id params[:albaranlinea][:albaran_id]
    if albaran && !albaran.cerrado
      albaranlinea = params[:id] ? AlbaranLinea.find(params[:id]) : AlbaranLinea.new
      albaranlinea.update_attributes params[:albaranlinea]
      albaran = Albaran.find_by_id params[:albaranlinea][:albaran_id]
      if albaran.cliente_id
        albaranlinea.precio_venta = params[:producto][:precio]
      end
      albaranlinea.producto_id = params[:producto][:id]
      albaranlinea.save
    end
    redirect_to :controller => :albarans, :action => :editar, :id => albaranlinea.albaran_id
  end

  def eliminar_linea
    albaran = Albaran.find_by_id params[:albaran_id]
    albaranlinea = AlbaranLinea.find_by_id params[:id] 
    if albaranlinea && albaran && !albaran.cerrado
      albaranlinea.destroy
    end
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

end
