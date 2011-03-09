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
    @factura = Factura.new
    @importe = params[:importe]
    render :partial => "cobrar_albaran", :albaran_id => params[:albaran_id]
  end

  def aceptar_cobro
    factura = Factura.new
    factura.update_attributes params[:factura]
    flash[:error] = factura
    redirect_to :controller => :albarans, :action => :aceptar_albaran, :id => factura.albaran_id
  end

  def calcula_cambio
    devolver = params[:recibido].to_f - params[:importe].to_f
    render :inline => devolver>=0 ? 'A Devolver<br/>' + devolver.to_s + ' €' : '&nbsp;'
  end

end
