class AlbaranLineasController < ApplicationController


  # Metodos AJAX de Lineas de Albaran

  def lineas
    albaran = Albaran.find(params[:albaran_id])
    @albaran_lineas = albaran.albaran_lineas 
    render :update do |page|
      page.replace_html params[:update], :partial => "lineas"
    end    
  end

  def editar
    @albaran_linea = AlbaranLinea.find(params[:id])
    render :partial => "editar", :albaran_id => params[:albaran_id]
  end

  def modificar
    @albaran_linea = AlbaranLinea.find(params[:id])
    @albaran_linea.update_attributes params[:albaran_linea]
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

  def asignar_linea
    albaran = Albaran.find_by_id params[:albaranlinea][:albaran_id]
    if albaran && !albaran.cerrado
      albaranlinea = params[:id] ? AlbaranLinea.find(params[:id]) : AlbaranLinea.new
      albaranlinea.producto_id = params[:producto][:id]
      albaranlinea.update_attributes params[:albaranlinea]

      if !Albaran.find_by_id(params[:albaranlinea][:albaran_id]).proveedor.nil?
        if params[:precios_relacionados][1].to_s == "true"
          producto = Producto.find_by_id(params[:producto][:id])
          preciodeventa = producto.precio
          albaranlinea.precio_compra = preciodeventa / (1 + producto.familia.iva.valor.to_f/100)
        else
          albaranlinea.precio_compra = params[:albaranlinea][:precio_compra].to_f
        end
      end
      albaranlinea.save

    end
    redirect_to :controller => :albarans, :action => :editar, :id => albaranlinea.albaran_id
  end

  def borrar 
    albaran = Albaran.find_by_id params[:albaran_id]
    albaranlinea = AlbaranLinea.find_by_id params[:id] 
    if albaranlinea && albaran && !albaran.cerrado
      albaranlinea.destroy
    end
    redirect_to :controller => :albarans, :action => :editar, :id => params[:albaran_id]
  end

end
