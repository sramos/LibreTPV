class ProductosEditorialController < ApplicationController

  def index
    session[("productos_editorial_filtrado").to_sym] = ""
    redirect_to :action => :listado
  end

  def filtrado
    session[("productos_editorial_filtrado_tipo").to_sym] = params[:filtro][:tipo] if params[:filtro]
    session[("productos_editorial_filtrado_valor").to_sym] = ( params[:filtro] && params[:filtro][:valor] != "" ) ? params[:filtro][:valor] : nil
    session[("productos_editorial_filtrado_condicion").to_sym] = params[:filtro] ? params[:filtro][:condicion] : nil
    redirect_to :action => :listado
  end

  def listado
    @campos_filtro = [["Nombre","productos.nombre"], ["Autor","autor.nombre"],
                      ["Cantidad","cantidad"],
                      ["Codigo","codigo"], ["Editor","editorial.nombre"],
                      ["Familia","familias.nombre"]]
    if params[:format_xls_count]
      paginado = params[:format_xls_count]
      page = 1
    else
      paginado = Configuracion.valor('PAGINADO')
      page = params[:page]
    end

    if session[("productos_editorial_filtrado_tipo").to_sym] && session[("productos_editorial_filtrado_valor").to_sym]
      @productos = case session[("productos_editorial_filtrado_tipo").to_sym]
        when "cantidad" then
          if /^[><=]$/.match(session[("productos_editorial_filtrado_condicion").to_sym])
            filtro_cantidad = ["sum(producto_editorial_x_almacenes.cantidad) #{session[("productos_editorial_filtrado_condicion").to_sym]} ?",
                                session[("productos_editorial_filtrado_valor").to_sym].to_i]
          else
            filtro_cantidad = "1=1"
          end
          Producto.joins(:producto_editorial).
                   joins(producto_editorial: :producto_editorial_x_almacenes).
                   having(filtro_cantidad).
                   order('productos.nombre ASC').
                   paginate(page: page, per_page: paginado)
        else
          Producto.joins(:producto_editorial).
                   joins(:familia, :editorial, :autor).
                   where([ session[("productos_editorial_filtrado_tipo").to_sym] + ' LIKE ?', "%" + session[("productos_editorial_filtrado_valor").to_sym] + "%" ]).
                   order('productos.nombre ASC').
                   paginate(page: page, per_page: paginado)
      end
    else
      @productos = Producto.joins(:producto_editorial).
                            order(:nombre).paginate(page: page, per_page: paginado)
    end
    if session[("productos_editorial_filtrado_tipo").to_sym] == "deposito"
      render "listado_deposito"
    else
      @formato_xls = @productos.total_entries
        respond_to do |format|
        format.html
        format.xls do
          @tipo = "inventario"
          @objetos = @productos
          render 'comunes_xls/listado', :layout => false
        end
      end
    end
  end


  # Devuelve un listado de los almacenes con el producto y su cantidad
  def listado_almacenes
    @pexa = ProductoEditorialXAlmacen.where(producto_editorial_id: params[:id]).
                                      joins(:almacen).
                                      order("almacenes.nombre").
                                      paginate(page: params[:page], per_page: Configuracion.valor('PAGINADO'))
    render :update do |page|
      page.replace_html params[:update], :partial => "almacenes"
    end
  end

  def editar
  end

  def modificar
  end

  def borrar
  end

end
