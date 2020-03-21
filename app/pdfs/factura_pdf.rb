class FacturaPdf < Prawn::Document
  # Inicializamos la clase
  def initialize(factura, view)
    @factura = factura
    super(page_size: "A4", margin: 30)
    font "Helvetica"
    font_size 9
    cabecera
    items
    pie
  end

  # Dibujamos la cabecera con los datos de la libreria
  def cabecera 
    #stroke_axis
    logopath =  "#{Rails.root}/public/images/logo_factura.png"
    y_pos = cursor
    bounding_box([50, y_pos], height: 100, width: 100) do
      image logopath, width: 80, height: 75
    end
    bounding_box([200, y_pos], height: 100, width: 330) do
      move_down 10
      font_size(12) do
        text Configuracion.valor('NOMBRE CORTO EMPRESA').upcase, align: :right
      end
      text Configuracion.valor('NOMBRE LARGO EMPRESA'), align: :right
      text "C.I.F. " + Configuracion.valor('CIF'), align: :right
      text Configuracion.valor('DIRECCION'), align: :right if Configuracion.valor('DIRECCION')
      text Configuracion.valor('CODIGO POSTAL'), align: :right if Configuracion.valor('CODIGO POSTAL')
      text "Tfn. " + Configuracion.valor('TELEFONO'), align: :right if Configuracion.valor('TELEFONO')
    end
    bounding_box([325, y_pos - 100], height: 100, width: 205) do
      text "Factura num.: " + @factura.codigo
      text "Fecha: " + @factura.fecha.strftime('%d/%m/%Y')
      text "Cliente: " + @factura.albarans.first.cliente.nombre
      text "N.I.F. " + @factura.albarans.first.cliente.cif
      text @factura.albarans.first.cliente.direccion if @factura.albarans.first.cliente.direccion
      text @factura.albarans.first.cliente.cp if @factura.albarans.first.cliente.cp
    end
  end

  def items
    iva_total = {}
    subtotal = precio_total = 0

    # Tabla de productos
    columnas = [ { :atribute => "cantidad", :title => '', :width => 25, :align => :right },
                 { :atribute => "nombre_producto", :title => 'Nombre', :width => 240 },
                 { :atribute => "precio_venta", :title => 'PVP', :width => 60, :format => "%.2f", :align => :right },
                 { :atribute => "descuento", :title => '%Dto', :width => 35, :align => :right },
                 { :atribute => "subtotal", :title => 'B.Imp.', :width => 60, :format => "%.2f", :align => :right },
                 { :atribute => "iva", :title => '%IVA', :width => 35, :align => :right },
                 { :atribute => "total", :title => 'Total', :width => 75, :format => "%.2f", :align => :right } ]
    # Guarda la cabecera de la tabla
    data = [ columnas.collect{|c| c[:title]} ]
    # Recoge los productos de la factura
    @factura.albarans.each do |alb|
      # Si la factura es de mas de un albaran, recorre todos
      alb.albaran_lineas.each do |linea|
        # Recoge los productos de un albaran
        fila = columnas.collect do |columna|
          columna[:format] ? format(columna[:format],linea.send(columna[:atribute])) : linea.send(columna[:atribute])
        end
        # Y calcula el iva, subtotal y total
        iva = linea.iva
        iva_total[iva] = iva_total.key?(iva) ? iva_total[iva] + (linea.total-linea.subtotal) : linea.total-linea.subtotal
        subtotal += linea.subtotal
        precio_total += linea.total
        # Incluye la linea de productos
        data.push fila 
      end
    end
    # Dibuja la tabla con los datos y el estilo definido
    style = { header: true, cell_style: {align: :right, size: 9}, column_widths: columnas.collect{|c| c[:width]}, row_colors: ["FFFFFF", "FCFCFC"] }
    table(data, style) do
      # Salvo la linea 0, que la hacemos en negrita y con fondo gris
      row(0).font_style = :bold 
      row(0).background_color = "B0B0B0"
      # y la columna del nombre de productos, que la alineamos a la izquierda
      column(1).align = :left
    end

    move_down 10

    # Tabla de totales
    style = { header: false, cell_style: {size: 10, borders: []}, column_widths: [265, 190, 75]  }
    data = [ ["", "Subtotal", format("%.2f", subtotal)] ]
    iva_total.each do |tipo, parcial|
      data.push ["", "IVA #{tipo}%", format("%.2f", parcial)]
    end
    data.push ["", "Total Euros (IVA incluido)", format("%.2f", precio_total)]
    table(data, style) do
      row(data.size - 1).font_style= :bold
      column(2).align = :right
    end
  end

  def pie
  end
end
