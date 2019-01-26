# encoding: UTF-8

class DepositoController < ApplicationController

  # Hace una busqueda de "albaranes" eliminando los vacios
  before_filter :obtiene_albaranes, :only => [ :listado ]

  def index
    flash[:mensaje] = "Listado de Albaranes en Depósito"
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
    session[("reposicion").to_sym][(albaran_linea.albaran_id.to_s).to_sym] ||= Hash.new
    session[("reposicion").to_sym][(albaran_linea.albaran_id.to_s).to_sym][(albaran_linea.id.to_s).to_sym] = params[:selector]
    render :update do |page|
      page.replace_html params[:update], :partial => "iconos_producto_deposito", :locals => { :linea => albaran_linea, :update => params[:update] }
      page.replace_html "caja_reposicion", :partial => "caja_reposicion"
      page.visual_effect :highlight, "caja_reposicion", :duration => 6
      page.replace_html 'MB_content', :inline => '<div id="mensajeok">Se ha incluido el elemento en la lista de reposición.<br></div>'
      page.call("Modalbox.resizeToContent")
    end
  end

  # Elimina de la lista de sustitucion
  def quitar_sustitucion_producto
    albaran_linea = AlbaranLinea.find_by_id params[:id]
    @albaran_lineas = albaran_linea.albaran.albaran_lineas
    session[("reposicion").to_sym][(albaran_linea.albaran_id.to_s).to_sym].delete((albaran_linea.id.to_s).to_sym)
    cantidad = 0
    session[("reposicion").to_sym].each_value { |elemento| elemento.each_value { |libros| cantidad += libros.size } } if session[("reposicion").to_sym]
    render :update do |page|
      page.replace_html "caja_reposicion", :partial => "caja_reposicion"
      page.replace_html("listado_reposicion", :partial => "lista_reposicion") if cantidad > 0 && params[:tipo] == "d"
      # Esto lo hacemos para evitar un casque si el objeto no existe en la pagina
      #page.select(params[:update]).each do |element|
        page.replace_html params[:update], :partial => "iconos_producto_deposito", :locals => { :linea => albaran_linea, :update => params[:update] }
      #end
      page.visual_effect :highlight, "caja_reposicion", :duration => 6
      page.replace_html 'MB_content', :inline => '<div id="mensajeok">Se ha eliminado el elemento de la lista de reposición.<br></div>'
      page.call("Modalbox.resizeToContent")
    end
  end

  # Mostrar la lista de reposicion
  def lista_reposicion
    render :update do |page|
      page.replace_html params[:update], :partial => "lista_reposicion"
    end
  end

  # Vaciar lista de reposicion
  def vaciar_lista_reposicion
    session[("reposicion").to_sym] = Hash.new
    redirect_to :action => :listado
  end

  # Reponer los productos de la lista de reposicion
  def reponer_productos
    # Genera los albaranes de pedido
    session[("reposicion").to_sym].each do |albaran_id,elemento|
      albaran_viejo = Albaran.find_by_id(albaran_id.to_s.to_i)
      #albaran = Albaran.create( albaran_viejo.attributes.merge(:fecha => Date.today, :cerrado => false, :codigo => "R-" + albaran_viejo.codigo) )
      albaran = Albaran.create( :fecha => Date.today, :proveedor_id => albaran_viejo.proveedor_id, :cerrado => false, :codigo => "R-" + albaran_viejo.codigo)
      elemento.each do |linea_id,cant|
        cantidad = cant["cantidad".to_sym].to_s
        al = AlbaranLinea.find_by_id(linea_id.to_s.to_i)
        linea = AlbaranLinea.create( al.attributes.merge({:cantidad => cantidad, :albaran_id => albaran.id}) )
        session[("reposicion").to_sym][albaran_id].delete(linea_id)
      end
      session[("reposicion").to_sym].delete(albaran_id)
    end
    session[("reposicion").to_sym] = Hash.new
    # Clona los albaranes de pedido como cerrados y con una factura asociada
    redirect_to :action => :listado
  end

  def borrar
    albaran = Albaran.find_by_id params[:id]
    if albaran && albaran.cerrado
      albaran.reabrir(params[:seccion])
      flash[:error] = albaran
    end
    redirect_to :action => :listado
  end

  private
    def obtiene_albaranes
      @albarans = Albaran.where("proveedor_id IS NOT NULL AND cerrado AND deposito").
                          order(:fecha_devolucion)
    end
end
