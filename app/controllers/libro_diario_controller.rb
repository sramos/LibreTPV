class LibroDiarioController < ApplicationController

  def index
    flash[:mensaje] = "Libro Diario."
    flash[:mensaje] << "<br>Informe de Facturas emitidas/recibidas para las fechas elegidas."
    redirect_to :action => :listado
  end

  def listado
    if cookies[("filtrado_fecha_inicio").to_sym] && cookies[("filtrado_fecha_fin").to_sym]
      @facturas = Factura.where('facturas.fecha' => cookies[("filtrado_fecha_inicio").to_sym]..cookies[("filtrado_fecha_fin").to_sym]).
                          order('facturas.fecha DESC, facturas.codigo DESC').
                          paginate(page: params[:page], per_page: Configuracion.valor('PAGINADO'))
    end
  end

end
