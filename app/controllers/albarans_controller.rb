class AlbaransController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Albaranes de Proveedores" if params[:seccion] == "productos"
    flash[:mensaje] = "Listado de Truekes" if params[:seccion] == "trueke"
    redirect_to :action => :listado
  end

  def listado
    albaranes
  end

  def editar
    if params[:id]
      @albaran = Albaran.find(params[:id])
      @albaran_lineas = @albaran.albaran_lineas
      @importe_total = 0;
      @albaran_lineas.each { |linea| @importe_total += (linea.producto.precio * linea.cantidad * (1 - linea.descuento.to_f/100) ) }
      params[:update] = 'lineas_albaran'
      params[:albaran_id] = @albaran.id
      render :action => :modificar
    else
      @proveedores = Proveedor.all
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
      if :seccion == "productos"
        multiplicador = 1
        flash[:mensaje] = "Albaran aceptado!"
      else
        multiplicador = -1
        flash[:mensaje] = "Pago realizado!"
      end
      lineas.each do |linea|
        producto=linea.producto
        producto.cantidad += (linea.cantidad * multiplicador)
        producto.save 
      end
    end
    redirect_to :action => :listado
  end

  def borrar
    albaran = Albaran.find_by_id params[:id]
    if albaran
      if albaran.cerrado
        lineas = albaran.albaran_lineas
        if :seccion == "productos"
          multiplicador = -1
        else
          multiplicador = 1
        end
        lineas.each do |linea|
          producto=linea.producto
          producto.cantidad += (linea.cantidad * multiplicador)
          producto.save  
        end
      end
      albaran.destroy
    end
    flash[:error] = albaran
    redirect_to :action => :listado
  end

  private
    def albaranes
      # Hace una limpieza de los albaranes vacios
      case params[:seccion]
        when "caja"
          condicion = "cliente_id"
          @clientes = Cliente.all
        when "productos"
          condicion = "proveedor_id"
          @proveedores = Proveedor.all
        when "trueke"
          condicion = "cliente_id"
      end
      @albarans = Albaran.find :all, :conditions => { :cerrado => false } 
      @albarans.each do |albaran|
        limpiar = false
        albaran.destroy if AlbaranLinea.find_by_albaran_id(albaran.id).nil?
      end
      @albarans = Albaran.find :all, :order => 'fecha DESC', :conditions => [ condicion + " IS NOT NULL AND cerrado IS ?", false ]
    end
end
