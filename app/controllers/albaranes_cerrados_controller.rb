# encoding: UTF-8
class AlbaranesCerradosController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Albaranes Cerrados"
    redirect_to :action => :listado
  end

  def listado
    # Albaranes de compra cerrados pero sin factura

    condicion  = "NOT deposito AND cerrado"
    condicion += " AND proveedor_id IS NOT NULL" unless session[("filtrado_proveedor").to_sym] && session[("filtrado_proveedor").to_sym] != ""
    condicion += " AND proveedor_id = " + session[("filtrado_proveedor").to_sym] if session[("filtrado_proveedor").to_sym] && session[("filtrado_proveedor").to_sym] != ""
    # Si hay un filtrado de fechas lo aplica
    condicion += " AND fecha BETWEEN '" + cookies[("filtrado_fecha_inicio").to_sym] + "' AND '" + cookies[("filtrado_fecha_fin").to_sym] + "'" if cookies[("filtrado_fecha_inicio").to_sym] && cookies[("filtrado_fecha_fin").to_sym]

    # Si hay filtrado de albaranes facturados lo aplica
    condicion += " AND factura_id IS NULL" if session[("filtrado_facturado").to_sym] && session[("filtrado_facturado").to_sym] == "false"
    condicion += " AND factura_id IS NOT NULL" if session[("filtrado_facturado").to_sym] && session[("filtrado_facturado").to_sym] == "true"

    @albaranes = Albaran.where(condicion).
                         order("fecha DESC, codigo DESC").
                         paginate(page: params[:format]=='xls' ? nil : params[:page],
                                  per_page: params[:format_xls_count] || Configuracion.valor('PAGINADO') )

    @formato_xls = @albaranes.total_entries
    respond_to do |format|
      format.html
      format.xls do
        @tipo = "albaranes_cerrados_" + params[:seccion]
        @objetos = @albaranes
        render 'comunes_xls/listado', :layout => false
      end
    end

  end

  def reabrir
    @albaran = Albaran.find_by_id params[:id]
    if @albaran && @albaran.cerrado
      @albaran.reabrir params[:seccion]
      flash[:error] = @albaran
    end
    redirect_to :action => 'listado'
  end

  def generar_factura
    @albaran = Albaran.find_by_id params[:id]
    # Genera una factura solo si no es de deposito ni tiene factura ya y esta cerrado
    if @albaran && !@albaran.deposito && @albaran.cerrado && @albaran.factura.nil?
      @factura = Factura.new
      @factura.fecha = Time.now
      @factura.codigo = "N/A"
      @factura.importe = @albaran.total
      @factura.albarans << @albaran
      @factura.save
      flash[:error] = @factura
      if @factura.errors.empty?
        render :partial => "factura/formulario", :locals => { :proveedor => (@albaran.proveedor.nombre if @albaran && @albaran.proveedor_id) }
      else
        render :inline => "<strong>ERROR:</strong><br/>" + @factura.errors.each {|e| e.to_s + "<br/>"}
      end
    else
      render :inline => "No se puede generar una factura de este Albarán"
    end
  end

end
