class LibroDiarioController < ApplicationController

  def index
    flash[:mensaje] = "Libro Diario."
    flash[:mensaje] << "<br>Informe de Facturas emitidas/recibidas para las fechas elegidas."
    redirect_to :action => :listado
  end

  def listado
    if session[("tesoreria_filtrado_fecha_inicio").to_sym] && session[("tesoreria_filtrado_fecha_fin").to_sym]
      @facturas = Factura.paginate :page => params[:page], :per_page => Configuracion.valor('PAGINADO'), :order => 'facturas.fecha DESC, facturas.codigo DESC', :conditions => { 'facturas.fecha' => session[("tesoreria_filtrado_fecha_inicio").to_sym]..session[("tesoreria_filtrado_fecha_fin").to_sym]}
    end
  end

end
