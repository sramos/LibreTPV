class AlbaransController < ApplicationController

  # Hace una busqueda de "albaranes" eliminando los vacios 
  before_filter :obtiene_albaranes, :only => [ :listado ]

  def index
    flash[:mensaje] = "Listado de Albaranes de Proveedores pendientes de aceptar" if params[:seccion] == "productos"
    flash[:mensaje] = "Listado de Truekes pendientes de aceptar" if params[:seccion] == "trueke"
    redirect_to :action => :listado 
  end

  def listado
  end

  def editar
    @proveedores = Proveedor.find(:all, :order => 'nombre') if params[:seccion] == "productos"
    @clientes = Cliente.find(:all, :order => 'nombre') if params[:seccion] == "caja"
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
    @albaran = params[:id] ? Albaran.find(params[:id]) : Albaran.new
    @albaran.update_attributes params[:albaran]
    redirect_to :action => :editar, :id => @albaran.id
  end

  # Segun la seccion borramos productos o los incluimos
  def aceptar_albaran
    albaran = Albaran.find_by_id params[:id]
    if albaran && !albaran.cerrado
      albaran.cerrado = true
      albaran.save
      lineas = albaran.albaran_lineas
      if params[:seccion] == "productos"
        multiplicador = 1
        flash[:mensaje] = "Albaran aceptado!"
      else
        multiplicador = -1
        if ( params[:forma_pago] && FormaPago.find_by_id(params[:forma_pago][:id]).caja )
          flash[:mensaje] = "Asegúrese de cobrar la venta!!!<div class='importe_medio'>Importe: " + params[:importe] + "€"
          flash[:mensaje] << "<br>Recibido: " + params[:recibido][0] + "€<br>Cambio: " + format("%.2f",(params[:recibido][0].to_f - params[:importe].to_f).to_s) + "€" if params[:recibido][0].to_f > 0
          flash[:mensaje] << "</div>"
        else
          flash[:mensaje] = "Pago realizado!"
        end 
      end
      lineas.each do |linea|
        # Modificamos el inventario si la linea corresponde a un producto registrado
        if linea.producto
          producto=linea.producto
          producto.cantidad += (linea.cantidad * multiplicador)
          producto.save 
        end
      end
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

  # Cambia el cliente de un albaran que se esta editando
  def cambiar_relaciones
    albaran=Albaran.find_by_id params[:id]
    albaran.proveedor_id = params[:proveedor_id] if params[:proveedor_id] && params[:seccion] == "productos"
    albaran.cliente_id = params[:cliente_id] if params[:cliente_id] && params[:seccion] == "caja"
    albaran.save
    render :inline => ""
  end

  private
    def obtiene_albaranes
      # Hace una limpieza de los albaranes vacios
      case params[:seccion]
        when "caja"
          condicion = "cliente_id"
          @clientes = Cliente.all
        when "productos"
          condicion = "proveedor_id"
          @proveedores = Proveedor.find :all, :order => 'nombre'
        when "trueke"
          condicion = "cliente_id"
      end
      @albarans = Albaran.find :all, :conditions => { :cerrado => false } 
      @albarans.each do |albaran|
        limpiar = false
        albaran.destroy if AlbaranLinea.find_by_albaran_id(albaran.id).nil?
      end
      @albarans = Albaran.find :all, :order => 'fecha DESC', :conditions => [ condicion + " IS NOT NULL AND NOT cerrado" ]
    end
end
