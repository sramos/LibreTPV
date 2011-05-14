# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def filtrado
    if params[:filtro]
      session[("filtrado_fecha_inicio").to_sym] = Date.civil(params[:filtro][:"fecha_inicio(1i)"].to_i,params[:filtro][:"fecha_inicio(2i)"].to_i,params[:filtro][:"fecha_inicio(3i)"].to_i)
      session[("filtrado_fecha_fin").to_sym] = Date.civil(params[:filtro][:"fecha_fin(1i)"].to_i,params[:filtro][:"fecha_fin(2i)"].to_i,params[:filtro][:"fecha_fin(3i)"].to_i)
    end
    redirect_to :action => :listado
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
