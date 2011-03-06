class FacturaController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Facturas de Proveedores" if params[:seccion] == "productos"
    flash[:mensaje] = "Listado de Facturas de Clientes" if params[:seccion] == "trueke"
    redirect_to :action => :listado
  end

  def listado
    @facturas = Factura.find :all
  end

  def cobrar_albaran
    @factura = params[:id] ? Factura.find(params[:id]) : Factura.new
  end

end
