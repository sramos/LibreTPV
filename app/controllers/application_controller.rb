# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

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
        when "trimestre"
          'YEAR(facturas.fecha) = ' + params[:filtro]["trimestre_anno(1i)".to_sym] +
                ' AND MONTH(facturas.fecha) >= ' + (params[:filtro][:trimestre].to_i * 3 + 1).to_s +
                ' AND MONTH(facturas.fecha) <= ' + (params[:filtro][:trimestre].to_i * 3 + 3).to_s
        when "anno"
          'YEAR(facturas.fecha) = ' + params[:filtro]["anno(1i)".to_sym]
      end
    else
      session[("tesoreria_filtrado_condicion").to_sym] = nil
    end
    redirect_to :action => :listado
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
