# encoding: UTF-8

class ProductosEditorialController < ApplicationController
  require 'net/http'

  def index
    session[("productos_filtrado").to_sym] = ""
    redirect_to :action => :listado
  end

  def filtrado
    session[("productos_filtrado_tipo").to_sym] = params[:filtro][:tipo] if params[:filtro]
    session[("productos_filtrado_valor").to_sym] = ( params[:filtro] && params[:filtro][:valor] != "" ) ? params[:filtro][:valor] : nil
    session[("productos_filtrado_condicion").to_sym] = params[:filtro] ? params[:filtro][:condicion] : nil
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

    if session[("productos_filtrado_tipo").to_sym] && session[("productos_filtrado_valor").to_sym]
      @productos = case session[("productos_filtrado_tipo").to_sym]
        when "cantidad" then
          Producto.joins(:producto_editorial).
                   where(["cantidad " + session[("productos_filtrado_condicion").to_sym] + " ?", session[("productos_filtrado_valor").to_sym].to_i]).
                   order('productos.nombre ASC').
                   paginate(page: page, per_page: paginado)
        else
          Producto.joins(:producto_editorial).
                   joins(:familia, :editorial, :autor).
                   where([ session[("productos_filtrado_tipo").to_sym] + ' LIKE ?', "%" + session[("productos_filtrado_valor").to_sym] + "%" ]).
                   order('productos.nombre ASC').
                   paginate(page: page, per_page: paginado)
      end
    else
      @productos = Producto.joins(:producto_editorial).
                            order(:nombre).paginate(page: page, per_page: paginado)
    end
    if session[("productos_filtrado_tipo").to_sym] == "deposito"
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

  def editar
    @familias = Familia.all
    if params[:codigo]
      #@producto = producto_x_codigo_isbn_con_imagen(params[:codigo])
      @producto = producto_x_codigo_isbn(params[:codigo])
    else
      @producto = Producto.find_by_id(params[:id]) || Producto.new
    end
    @materias = @producto.familia.materia.order("materia.nombre") if @producto.id
    #@producto_familia_id = @producto.familia_id if @producto.id
    if params[:inventario]
      render :partial => "formulario"
    else
      render :partial => "propiedades"
    end
  end

  def modificar
    @producto = params[:id] ?  Producto.find(params[:id]) : Producto.new
    @producto.update_attributes params[:producto]
    # Aunque no guardemos, tenemos que hacer esto para que no casque al vincular a flash
    @producto.imagen = nil
    # Y por fin, mostramos la salida
    if params[:inventario]
      flash[:error] = @producto
      redirect_to action: :listado, page: params[:page]
    else
      render :update do |page|
        page.replace_html params[:update], :partial => "listado_propiedades"
        page.visual_effect :highlight, params[:update] , :duration => 6
        page.replace 'formulario_ajax', :inline => '<%= mensaje_error(@producto) %><br>'
        page.call("Modalbox.resizeToContent")
      end
    end
  end

  def borrar
    @producto = Producto.find_by_id(params[:id])
    @producto.destroy
    flash[:error] = @producto.errors.full_messages.join(" ")
    redirect_to action: :listado, page: params[:page]
  end

  # Ajax para el cambio la familia de un producto (implica cambio en materia tambien)
  def refresca_formulario_materia
    @producto = Producto.find_by_id(params[:id])
    familia = Familia.find_by_id(params[:familia_id])
    @materias = familia.materia.order("materia.nombre")
    @valor_materia_defecto = familia.materia_defecto_id if @producto && familia && @producto.familia_id != familia.id
    render partial: 'formulario_materia'
  end

  # Busca imagen y descripcion en internet
  def update_datos_externos
    @producto = Producto.find_by_id(params[:id]) || Producto.new(:codigo => params[:codigo])
    if params[:codigo]
      @producto.get_remote_description if @producto.descripcion.nil? || @producto.descripcion == ""
      @producto.get_remote_image
      @producto.save if @producto.id
      render :update do |page|
        page.replace params[:update], :partial => 'datos_externos'
        page.call("Modalbox.resizeToContent")
      end
    end
  end

  # Busca descripcion en internet
  def search_description
    @producto = Producto.find_by_id(params[:id]) || Producto.new(codigo: params[:codigo])
    if params[:codigo]
      @producto.get_remote_description
      render :update do |page|
        page.replace params[:update], :partial => 'datos_externos_descripcion'
        page.call("Modalbox.resizeToContent")
      end
    end
  end

  # Busca imagen en internet
  def search_cover
    @producto = Producto.find_by_id(params[:id]) || Producto.new(codigo: params[:codigo])
    if params[:codigo]
      @imagenes = @producto.get_available_images
      render :update do |page|
        page.replace params[:update], :partial => 'seleccion_imagen'
        page.call("Modalbox.resizeToContent")
      end
    end
  end

  # Actualiza la descripcion asociada al libro
  def update_description
    @producto = Producto.find_by_id(params[:id]) || Producto.new(descripcion: params[:description])
    if params[:description] && @producto
      @producto.update_attribute(:descripcion, params[:description]) if @producto.id
      render :update do |page|
        page.replace params[:update], :partial => 'datos_externos'
        page.call("Modalbox.resizeToContent")
      end
    end
  end

  # Actualiza la imagen asociada al libro descargandosela si no esta ya
  def update_cover
    # No actualizamos el producto, sino solo su imagen. Los datos se guardaran cuando se salve el texto
    @producto = Producto.find_by_id(params[:id]) || Producto.new(codigo: params[:codigo])
    if @producto
      # Actualizamos la imagen segun el origen que tengamos
      case params[:source]
      # Si elegimos la imagen ya cargada, nos aseguramos de que no exista la url
      when "uploaded"
        @producto.url_imagen = nil
      # Cuando no queremos, elimina la imagen
      when "none"
        @producto.url_imagen = nil
        @producto.imagen = nil
      # En cualquier otro caso, descarga la imagen y la sube como adjunto
      else
        @producto.url_imagen = params[:image]
      end
      render :update do |page|
        page.replace params[:update], :partial => 'datos_externos_imagen'
        page.call("Modalbox.resizeToContent")
      end
    end
  end

  # Autocomplete para editoriales
  def auto_complete_for_producto_editor
    @editores = Editorial.where(['nombre like ?', "%#{params[:search]}%"]).order(:nombre)
    render :inline => "<%= auto_complete_result_2 @editores, :nombre %>"
  end

  # Actualiza la familia del producto
  #def cambio_familia
  #  @producto = params[:id] ? Producto.find(params[:id]) : nil
  #  @producto.familia.id = params[:producto_familia_id]
  #  @producto_familia_id = params[:producto_familia_id]
  #  @familias = Familia.all
#
#    render :partial => "propiedades"
#  end

  def etiqueta
    producto = params[:id] ? Producto.find(params[:id]) : nil
    if producto
      barcode = Barby::Code128B.new(producto.codigo)
      altura_codigo = 30
      #pdf = PDF::Writer.new(:paper => 'C8', :orientation => :landscape)
      pdf = PDF::Writer.new( :paper => [8.8,5] )
      pdf.margins_mm(5)
      pdf.y = pdf.absolute_top_margin - 5
      pdf.text Configuracion.valor('NOMBRE CORTO EMPRESA').upcase, :justification => :center, :font_size => 10
      pdf.add_image barcode.to_jpg(:height => altura_codigo, :margin => 5), pdf.left_margin + 10, pdf.y - 52
      pdf.move_pointer altura_codigo + 20
      pdf.text producto.codigo, :font_size => 8, :left => 15
      pdf.move_pointer 10
      pdf.text producto.nombre.first(32)+" ...", :justification => :right, :right => 5, :font_size => 9
      pdf.text "PVP: " + format("%.2f",producto.precio.to_s) + " euros", :justification => :right, :right => 5
      pdf.rounded_rectangle(pdf.left_margin, pdf.absolute_top_margin, pdf.margin_width,
                      pdf.margin_height, 5).stroke

      send_data pdf.render, :filename => 'Etiqueta_' + producto.nombre + '.pdf', :type => 'application/pdf'
      #barcode = Barby::Code128B.new(producto.codigo)
      #File.open('/tmp/code128b.png', 'w') do |f|
      #  f.write barcode.to_png(:height => 20, :margin => 5)
      #end
    end
  end

  # Devuelve sublistado de proveedores del producto
  def albaranes_compra
    lineas = AlbaranLinea.find :all, :conditions=>{:producto_id => params[:id]}
    # Obtiene los albaranes donde esta el producto
    @albaranes=[]
    lineas.each { |linea| @albaranes.push(linea.albaran) if linea.albaran && linea.albaran.proveedor && linea.albaran.cerrado }
    # Elimina los albaranes duplicados
    @albaranes.uniq!
    render :update do |page|
      page.replace_html params[:update], :partial => "albaranes", :locals => { :compra => true }
    end
  end

  # Devuelve sublistado de ventas del producto
  def albaranes_venta
    lineas = AlbaranLinea.where(producto_id: params[:id])
    # Obtiene los albaranes donde esta el producto
    @albaranes=[]
    lineas.each { |linea| @albaranes.push(linea.albaran) if linea.albaran && linea.albaran.cliente && linea.albaran.cerrado }
    # Elimina los albaranes duplicados
    @albaranes.uniq!
    render :update do |page|
      page.replace_html params[:update], :partial => "albaranes", :locals => { :compra => false }
    end
  end

  def producto_x_codigo
    @producto = Producto.find_by_codigo(params[:codigo])
    @familias = Familia.all

    if params[:codigo]==""
      render :inline => ""

    # Si existe el libro coge los datos y envia el formulario
    elsif !@producto.nil?
      render :partial => params[:template]

    # Si no existe el libro lo busca y se prepara para guardarlos
    else
      @producto = producto_x_codigo_isbn params[:codigo]
      if @producto.familia
        @materias = @producto.familia.materia
	materia_defecto = @producto.familia.materia.find_by_valor_defecto(true)
        @valor_materia_defecto = materia_defecto.id if materia_defecto
      end
      render :partial => params[:template]
    end
  end

  def producto_x_titulo
    puts "-----> nos llaman para meter el codigo ean " + params[:titulo]
    if @producto = Producto.where(nombre: params[:titulo]).first
      render :update do |page|
        page.replace 'formulario_campo_producto_codigo', :inline => '<%= text_field("producto", "codigo", {:class => "texto", :id => "formulario_campo_producto_codigo", :type => "d", :value => @producto.codigo }) %>'
        page.replace 'propiedades_producto', :partial => 'productos/listado_propiedades'
      end
    else
      render nothing: true
    end
  end

end
