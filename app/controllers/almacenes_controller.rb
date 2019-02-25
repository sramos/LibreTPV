class AlmacenesController < ApplicationController
  before_filter :obtiene_almacen, :except => [ :index, :listado ]

  def index
    flash[:mensaje] = "Listado de Almacenes"
    redirect_to :action => :listado
  end

  def listado
    @almacenes = Almacen.order(:nombre)
  end

  def listado_productos
    @pexa = ProductoEditorialXAlmacen.where(almacen_id: @almacen.id).
                                      where("producto_editorial_x_almacenes.cantidad != 0").
                                      joins(producto_editorial: :producto).
                                      order("productos.nombre ASC").
                                      paginate(page: params[:page], per_page: Configuracion.valor('PAGINADO'))
    puts "-----------> Parece que tenemos " + @pexa.inspect
    render :update do |page|
      page.replace_html params[:update], partial: "productos"
    end
  end

  def editar
    @almacen ||= Almacen.new
    render :partial => "formulario"
  end

  def modificar
    @almacen ||= Almacen.new
    @almacen.update_attributes params[:almacen]
    flash[:error] = @almacen
    redirect_to :action => :listado
  end

  def borrar
    @almacen = Almacen.find_by_id(params[:id])
    @almacen.destroy if @almacen
    flash[:error] = @almacen
    redirect_to :action => :listado
  end

  private

  def obtiene_almacen
    @almacen = Almacen.find_by_id(params[:id])
  end

end
