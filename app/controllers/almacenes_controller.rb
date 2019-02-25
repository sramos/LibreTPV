class AlmacenesController < ApplicationController
  before_filter :obtiene_almacen, :only => [ :editar, :modificar, :borrar ]

  def index
    flash[:mensaje] = "Listado de Almacenes"
    redirect_to action: :listado
  end

  def listado
    @almacenes = Almacen.order(:nombre)
  end

  def editar
    @almacen ||= Almacen.new
    render partial: "formulario"
  end

  def modificar
    @almacen ||= Almacen.new
    @almacen.update_attributes params[:almacen]
    flash[:error] = @almacen
    redirect_to action: :listado
  end

  def borrar
    @almacen.destroy if @almacen
    flash[:error] = @almacen
    redirect_to action: :listado
  end

  ###
  # Metodos asociados a productos del almacen
  ###

  # Listado de los productos de un almacen
  def listado_productos
    @pexas = ProductoEditorialXAlmacen.where(almacen_id: params[:id]).
                                       where("producto_editorial_x_almacenes.cantidad != 0").
                                       joins(producto_editorial: :producto).
                                       order("productos.nombre ASC")
    render :update do |page|
      page.replace_html params[:update], partial: "productos"
    end
  end

  # Prepara el formulario de movimiento de ejemplares a otro almacen
  def editar_mover_productos
    @pexa = ProductoEditorialXAlmacen.find_by_id params[:pexa_id]
    @almacenes = Almacen.where("id != ?", @pexa.almacen_id).order(:nombre)
    render partial: "formulario_mover"
  end

  # Registra un movimiento de elementos de un almacen a otro
  def modificar_mover_productos
    pexa_origen = ProductoEditorialXAlmacen.find_by_id params[:pexa_id]
    almacen_destino = Almacen.find_by_id params[:almacen_destino_id]
    cantidad = params[:cantidad].to_i
    if pexa_origen && almacen_destino && cantidad > 0 && cantidad <= pexa_origen.cantidad
      pexa_destino = almacen_destino.producto_editorial_x_almacenes.
                                     find_or_initialize_by(producto_editorial_id: pexa_origen.producto_editorial_id)
      pexa_destino.cantidad += cantidad
      pexa_destino.save
      pexa_origen.update_attributes(cantidad: (pexa_origen.cantidad - cantidad) ) if pexa_destino.errors.empty?
    else
      flash[:error] = "No se pudo encontrar el almacen de destino." unless almacen_destino
      flash[:error] = "No se pudo encontrar el stock en el almacen de origen" unless pexa_origen
      flash[:error] = "No se pueden mover más libros que los que existen en el almacen (%d)"%[pexa_origen.cantidad] if pexa_origen && almacen_destino
    end
    @pexas = ProductoEditorialXAlmacen.where(almacen_id: pexa_origen.almacen_id).
                                       where("producto_editorial_x_almacenes.cantidad != 0").
                                       joins(producto_editorial: :producto).
                                       order("productos.nombre ASC")
    render :update do |page|
      page.replace_html "MB_content", inline: flash[:error]||"Ejemplares movidos correctamente"
      page.replace_html params[:update], partial: "productos"
    end
  end

  private

  def obtiene_almacen
    @almacen = Almacen.find_by_id(params[:id])
  end

end
