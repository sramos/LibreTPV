class ProveedorController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Proveedores"
    redirect_to :action => :listado
  end

  def listado
    @proveedores = Proveedor.all
  end

  def editar
    @proveedor = params[:id] ? Proveedor.find(params[:id]) : Proveedor.new
    render :partial => "formulario"
  end

  def modificar
    proveedor = params[:id] ? Proveedor.find(params[:id]) : Proveedor.new
    proveedor.update_attributes params[:proveedor]
    flash[:error] = proveedor 
    redirect_to :action => :listado
  end

  def borrar
    proveedor = Proveedor.find_by_id params[:id]
    proveedor.destroy
    flash[:error] = proveedor 
    redirect_to :action => :listado
  end

  # Devuelve sublistado de productos comprados al proveedor
  def productos
    albaranes = Albaran.find :all, :conditions => { :proveedor_id => params[:id], :cerrado => true }
    # Obtiene las líneas de cada albaran del proveedor
    @lineas = []
    albaranes.each { |albaran| albaran.albaran_lineas.each { |linea| @lineas.push(linea) } }
    #puts "--------------->" + @lineas.to_s
    render :update do |page|
      page.replace_html params[:update], :partial => "productos"
    end
  end

end
