# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# Libreria para salida a hoja de calculo
require 'spreadsheet'
# Librerias para paginado
require 'will_paginate'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_action :authenticate_user!

  def filtrado
    if params[:filtro]
#      cookies[("filtrado_fecha_inicio").to_sym] = { :value => Date.civil(params[:filtro][:"fecha_inicio(1i)"].to_i,params[:filtro][:"fecha_inicio(2i)"].to_i,params[:filtro][:"fecha_inicio(3i)"].to_i), :expires => 5.days.from_now }
#      cookies[("filtrado_fecha_fin").to_sym] = { :value => Date.civil(params[:filtro][:"fecha_fin(1i)"].to_i,params[:filtro][:"fecha_fin(2i)"].to_i,params[:filtro][:"fecha_fin(3i)"].to_i), :expires => 5.days.from_now }
      cookies[("filtrado_tipo_fecha").to_sym] = { :value => params[:filtro][:tipo_fecha], :expires => 5.day.from_now } if params[:filtro][:tipo_fecha]
      cookies[("filtrado_fecha_inicio").to_sym] = { :value => params[:filtro][:fecha_inicio].to_date.to_s, :expires => 5.days.from_now }
      cookies[("filtrado_fecha_fin").to_sym] = { :value => params[:filtro][:fecha_fin].to_date.to_s, :expires => 5.days.from_now }
      session[("filtrado_proveedor").to_sym] = (params[:filtro][:proveedor]=="0" ? nil : params[:filtro][:proveedor]) if params[:filtro][:proveedor]
      session[("filtrado_cliente").to_sym] = (params[:filtro][:cliente]=="0" ? nil : params[:filtro][:cliente]) if params[:filtro][:cliente]
      session[("filtrado_pagado").to_sym] = (params[:filtro][:pagado]=="0" ? nil : params[:filtro][:pagado]) if params[:filtro][:pagado]
      session[("filtrado_facturado").to_sym] = (params[:filtro][:facturado]=="0" ? nil : params[:filtro][:facturado]) if params[:filtro][:facturado]
    end
    redirect_to :action => :listado
  end

  # Para usar en exportaciones a XLS
  def xls_filename
    params[:seccion]+"-" + params[:controller] + "-" + params[:action] + ".xls"
  end

end
