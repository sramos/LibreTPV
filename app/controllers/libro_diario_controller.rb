class LibroDiarioController < ApplicationController

  def index
    flash[:mensaje] = "Libro Diario."
    flash[:mensaje] << "<br>Informe de Facturas emitidas/recibidas para las fechas elegidas."
    redirect_to :action => :listado
  end

  def filtrado
    session[("tesoreria_filtrado_tipo").to_sym] = params[:filtro][:tipo] if params[:filtro]
    if params[:filtro]
      session[("tesoreria_filtrado_condicion").to_sym] = case params[:filtro][:tipo]
        when "dia"
          'YEAR(facturas.fecha) = ' + params[:filtro]["dia(1i)".to_sym] + 
		' AND MONTH(facturas.fecha) = ' + params[:filtro]["dia(2i)".to_sym] + 
		' AND DAY(facturas.fecha) = ' + params[:filtro]["dia(3i)".to_sym]
        when "mes"
          'YEAR(facturas.fecha) = ' + params[:filtro]["mes(1i)".to_sym] +
                ' AND MONTH(facturas.fecha) = ' + params[:filtro]["mes(2i)".to_sym]
        when "anno"
          'YEAR(facturas.fecha) = ' + params[:filtro]["anno(1i)".to_sym]
      end 
    else
      session[("tesoreria_filtrado_condicion").to_sym] = nil
    end
    redirect_to :action => :listado
  end

  def listado
    @campos_filtro = [["Día","dia"], ["Mes","mes"], ["Año","anno"]]
    if session[("tesoreria_filtrado_condicion").to_sym]
      @facturas = Factura.paginate :page => params[:page], :per_page => Configuracion.valor('PAGINADO'), :order => 'facturas.fecha DESC, facturas.codigo DESC', :conditions => [session[("tesoreria_filtrado_condicion").to_sym]]
    end
  end

end
