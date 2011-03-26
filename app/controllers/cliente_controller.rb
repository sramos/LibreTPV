class ClienteController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Clientes"
    redirect_to :action => :listado
  end

  def listado
    @clientes = Cliente.all
  end

  def editar
    @cliente = params[:id] ? Cliente.find(params[:id]) : Cliente.new
    render :partial => "formulario"
  end

  def modificar
    cliente = params[:id] ? Cliente.find(params[:id]) : Cliente.new
    cliente.update_attributes params[:cliente]
    flash[:error] = cliente
    redirect_to :action => :listado
  end

  def borrar
    cliente = Cliente.find_by_id params[:id]
    cliente.destroy
    flash[:error] = cliente 
    redirect_to :action => :listado
  end

  # Devuelve sublistado de productos vendidos al cliente 
  def productos
    albaranes = Albaran.find :all, :conditions => { :cliente_id => params[:id], :cerrado => true }
    # Obtiene las líneas de cada albaran del proveedor
    @lineas = []
    albaranes.each { |albaran| albaran.albaran_lineas.each { |linea| @lineas.push(linea) } }
    puts "--------------->" + @lineas.to_s
    render :update do |page|
      page.replace_html params[:update], :partial => "productos"
    end
  end
end
