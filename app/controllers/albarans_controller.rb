class AlbaransController < ApplicationController

  # Hace una busqueda de "albaranes" eliminando los vacios
  before_filter :obtiene_albaranes, :only => [ :listado ]

  def index
    flash[:mensaje] = "Listado de Albaranes de Proveedores pendientes de aceptar" if params[:seccion] == "productos"
    flash[:mensaje] = "Ventas/Devoluciones Nuevas y Abiertas" if params[:seccion] == "caja"
    flash[:mensaje] = "Listado de Truekes pendientes de aceptar" if params[:seccion] == "trueke"
    redirect_to :action => :listado
  end

  def listado
  end

  def editar
    @proveedores = Proveedor.order(:nombre) if params[:seccion] == "productos"
    @clientes = Cliente.order(:nombre) if params[:seccion] == "caja"
    if params[:id]
      @albaran = Albaran.find(params[:id])
      @albaran_lineas = @albaran.albaran_lineas
      @importe_total = 0;
      @albaran_lineas.each do |linea|
        @importe_total += linea.total
      end
      params[:update] = 'lineas_albaran'
      params[:albaran_id] = @albaran.id
      params[:descuento] = @albaran.cliente.nil? ? @albaran.proveedor.descuento : @albaran.cliente.descuento
      render :action => :modificar
    end
  end

  def modificar
    @albaran = Albaran.find_by_id(params[:id]) || Albaran.new
    @albaran.update_attributes params[:albaran]
    redirect_to :action => :editar, :id => @albaran.id
  end

  # Segun la seccion borramos productos o los incluimos
  def aceptar_albaran
    flash[:mensaje_ok] = params[:mensaje_ok] if params[:mensaje_ok]
    flash[:error] = params[:error] if params[:error]
    albaran = Albaran.find_by_id(params[:id]||params[:albaran_id])
    if albaran && !albaran.cerrado
      if params[:seccion] == "productos"
        flash[:mensaje] = "Albaran aceptado!"
      end
      albaran.cerrar(params[:seccion])
    end
    redirect_to :action => :listado
  end

  def borrar
    albaran = Albaran.find_by_id params[:id]
    if albaran && !albaran.cerrado
      albaran.destroy
      flash[:error] = albaran
    end
    redirect_to :action => :listado
  end

  def auto_complete_for_libro_titulo
    @productos = Producto.where(['nombre like ?', "%#{params[:search]}%"])
    render :inline => "<%= auto_complete_result_2 @productos, :nombre %>"
  end


  private
    def obtiene_albaranes
      # Hace una limpieza de los albaranes vacios
      case params[:seccion]
        when "caja"
          condicion = "cliente_id"
          @clientes = Cliente.order(:nombre)
        when "productos"
          condicion = "proveedor_id"
          @proveedores = Proveedor.order(:nombre)
        when "trueke"
          condicion = "cliente_id"
      end
      @albarans = Albaran.where(cerrado: false)
      @albarans.each do |albaran|
        limpiar = false
        albaran.destroy if AlbaranLinea.find_by_albaran_id(albaran.id).nil?
      end
      @albarans = Albaran.where(condicion + " IS NOT NULL AND NOT cerrado").order("fecha DESC")
    end
end
