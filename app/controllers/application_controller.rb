# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def filtrado
    if params[:filtro]
#      cookies[("filtrado_fecha_inicio").to_sym] = { :value => Date.civil(params[:filtro][:"fecha_inicio(1i)"].to_i,params[:filtro][:"fecha_inicio(2i)"].to_i,params[:filtro][:"fecha_inicio(3i)"].to_i), :expires => 5.days.from_now }
#      cookies[("filtrado_fecha_fin").to_sym] = { :value => Date.civil(params[:filtro][:"fecha_fin(1i)"].to_i,params[:filtro][:"fecha_fin(2i)"].to_i,params[:filtro][:"fecha_fin(3i)"].to_i), :expires => 5.days.from_now }
      cookies[("filtrado_fecha_inicio").to_sym] = { :value => params[:filtro][:fecha_inicio], :expires => 5.days.from_now }
      cookies[("filtrado_fecha_fin").to_sym] = { :value => params[:filtro][:fecha_fin], :expires => 5.days.from_now }
      session[("filtrado_proveedor").to_sym] = (params[:filtro][:proveedor]=="0" ? nil : params[:filtro][:proveedor]) if params[:filtro][:proveedor]
      session[("filtrado_cliente").to_sym] = (params[:filtro][:cliente]=="0" ? nil : params[:filtro][:cliente]) if params[:filtro][:cliente]
      session[("filtrado_pagado").to_sym] = (params[:filtro][:pagado]=="0" ? nil : params[:filtro][:pagado]) if params[:filtro][:pagado]
    end
    redirect_to :action => :listado
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
