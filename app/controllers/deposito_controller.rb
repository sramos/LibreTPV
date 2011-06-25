class DepositoController < ApplicationController

  # Hace una busqueda de "albaranes" eliminando los vacios 
  before_filter :obtiene_albaranes, :only => [ :listado ]

  def index
    flash[:mensaje] = "Listado de Albaranes en Depósito" if params[:seccion] == "productos"
    redirect_to :action => :listado 
  end

  def listado
  end

  # Prepara el formulario de sustitución de producto
  def preparar_sustitucion_producto
    @albaran_linea = AlbaranLinea.find_by_id params[:id]
    render :partial => "formulario"
  end

  # Según el título elegido genera la sustitucion del producto
  def sustituir_producto
    albaran_linea = AlbaranLinea.find_by_id params[:albaran_linea_id]
    @albaran_lineas = albaran_linea.albaran.albaran_lineas
    session[("reposicion").to_sym] ||= Hash.new
    session[("reposicion").to_sym][(albaran_linea.albaran.proveedor_id.to_s + albaran_linea.albaran.fecha_devolucion.to_s).to_sym] ||= Hash.new
    session[("reposicion").to_sym][(albaran_linea.albaran.proveedor_id.to_s + albaran_linea.albaran.fecha_devolucion.to_s).to_sym][(albaran_linea.id.to_s).to_sym] = params[:selector]
    render :update do |page|
      page.replace_html params[:update], :partial => "albaran_lineas/lineas"
      page.visual_effect :highlight, params[:update] , :duration => 6
      page.replace_html 'MB_content', :inline => '<div id="mensajeok">Se ha incluido el elemento en la lista de reposición.<br></div>'
      page.call("Modalbox.resizeToContent")
    end
  end

  # Elimina de la lista de sustitucion
  def quitar_sustitucion_producto
    albaran_linea = AlbaranLinea.find_by_id params[:id]
    @albaran_lineas = albaran_linea.albaran.albaran_lineas
    session[("reposicion").to_sym][(albaran_linea.albaran.proveedor_id.to_s + albaran_linea.albaran.fecha_devolucion.to_s).to_sym].delete((albaran_linea.id.to_s).to_sym)
    render :update do |page|
      page.replace_html params[:update], :partial => "albaran_lineas/lineas"
      page.visual_effect :highlight, params[:update] , :duration => 6
      page.replace_html 'MB_content', :inline => '<div id="mensajeok">Se ha eliminado el elemento de la lista de reposición.<br></div>'
      page.call("Modalbox.resizeToContent")
    end
  end

  def borrar
    albaran = Albaran.find_by_id params[:id]
    if albaran && !albaran.cerrado
      albaran.destroy
      flash[:error] = albaran
    end
    redirect_to :action => :listado 
  end

  private
    def obtiene_albaranes
      @albarans = Albaran.find :all, :order => 'fecha DESC', :conditions => [ "proveedor_id IS NOT NULL AND cerrado AND deposito" ]
    end
end
