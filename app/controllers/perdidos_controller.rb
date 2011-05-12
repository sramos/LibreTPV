class PerdidosController < ApplicationController

  def index
    flash[:mensaje] = "Listado de elementos 'Perdidos'"
    redirect_to :action => :listado
  end

  def listado
    # Pagos perdidos (sin factura asociada)

    # Facturas perdidas (sin albaran asociado)
    #@facturas = Factura.find :all, :conditions => { :albaran_id => nil }
    #Factura.find(:all,:conditions => {:albaran_id => !nil}).each do |factura|
    #  @facturas.push(factura) if factura.albaran.nil?
    #end

    # Albaranes de compra perdidos (cerrados pero sin factura)
    @albaranes_compra = []
    Albaran.find(:all, :conditions => { :cerrado => true, :cliente_id => nil }).each do |albaran|
      puts "---> (" + albaran.id.to_s + ") " + albaran.proveedor.nombre + " " + albaran.fecha.to_s if albaran.factura.nil?
      @albaranes_compra.push(albaran) if albaran.factura.nil?
    end

    # Albaranes de venta perdidos (cerrados pero sin factura)
    @albaranes_venta = []
    Albaran.find(:all, :conditions => { :cerrado => true, :proveedor_id => nil }).each do |albaran|
      puts "---> (" + albaran.id.to_s + ") " + albaran.proveedor.nombre + " " + albaran.fecha.to_s if albaran.factura.nil?
      @albaranes_venta.push(albaran) if albaran.factura.nil?
    end

    # Líneas de albaran perdidas (sin albaran asociado)
    
    render "listado"
  end

  def recuperar_albaran
    @albaran = Albaran.find params[:albaran_id]
    @albaran.cerrado = false
    @albaran.save
    flash[:error] = @albaran
    redirect_to :action => 'listado'
  end

end
