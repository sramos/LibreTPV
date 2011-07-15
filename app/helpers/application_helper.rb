# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def cabecera_listado campos, otros={}
    @campos_listado = campos
    cadena = "<div class='listado'><div class='listadocabecera'>"
    for campo in campos
      cadena += "<div class='listado_campo_" + etiqueta(campo)[1] + (etiqueta(campo)[3]||"") + "' id='listado_campo_etiqueta_" + campo + "'>" + etiqueta(campo)[0] + "</div>"
    end
    cadena += "<div class='listado_derecha'>"
    #cadena += link_to icono('Plus',{:title => "Nuevo"}), {:action => 'editar'}
    cadena += modal icono('Plus',{:title => "Nuevo"}), otros[:url], otros[:title] || "Nuevo" if otros[:url]
    cadena += "</div></div>"
    return cadena
  end

  def fila_listado objeto, id=nil
    cadena = ""
    i=0
    for campo in @campos_listado
      if objeto.class.name == "Array"
        valor=objeto[i] || ""
      else
        valor=objeto
        campo.split('.').each { |metodo| valor = valor.send(metodo) if valor } if objeto
      end
      i += 1
      etiqueta=etiqueta(campo)
      valor = valor.localtime.strftime("%d/%m/%Y %H:%M:%S") if valor.class.name == "ActiveSupport::TimeWithZone"
      valor = valor.strftime("%d/%m/%Y") if valor.class.name == "Date"
      cadena += "<div class='listado_campo_" + etiqueta[1] + (etiqueta[3]||"") + "' id='listado_campo_valor_" + campo + (objeto.class.name == "Array" ? "" : "_" + objeto.id.to_s) + "'>" + (valor && valor.to_s != "" ? truncate( (etiqueta[3]=="f"?sprintf("%.2f",valor):valor.to_s), :length => etiqueta[2]):"&nbsp;") + '</div>'
    end
    #cadena += "</div>"
    return cadena
  end

  def final_listado objeto=nil
    cadena = ""
    cadena << "<div class='linea' id='paginado'><br/></div><div class='elemento_derecha'>" + (will_paginate(objeto) || "") + "</div>" if !objeto.nil?
    cadena << "</div>"
    return cadena
  end

  def cabecera_sublistado rotulo, campos, sub_id, nuevo={}
    @campos_sublistado = campos     
    script = "document.getElementById('" +  sub_id + "').innerHTML=\"\";" if sub_id
    cadena = '<br><fieldset class="sublistado"> <legend>'+ rotulo +'</legend>'
    cadena << '<div class="listado_derecha" id="cerrarsublistado">'
    cadena << link_to_function( icono('Cancel',{:Title => "Ocultar"}), script, {:id => sub_id + "_ocultar_sublistado"} ) if sub_id
    cadena << "</div><br/><br/><div class='listadocabecera'>"
    for campo in campos
      cadena << "<div class='listado_campo_" + etiqueta(campo)[1] + (etiqueta(campo)[3]||"") + "' id='sublistado_campo_valor_" + campo + "' >" + etiqueta(campo)[0] + "</div>"
    end
    if nuevo[:url] && nuevo[:title]
      cadena << '<div class="listado_derecha">'
      cadena << modal(icono('Plus',{:title => nuevo[:title]}), nuevo[:url], nuevo[:title])
      cadena << '</div>'
    end
    cadena << '</div>'
  end

  def fila_sublistado objeto
    cadena = ""
    for campo in @campos_sublistado
      valor=objeto
      campo.split('.').each { |metodo| valor = valor.send(metodo) if valor }
      valor = format('%0.2f',valor) if etiqueta(campo)[3] == "f" && valor
      valor = valor.strftime("%d/%m/%Y") if valor.class.name == "Date"
      cadena += "<div class='listado_campo_" + etiqueta(campo)[1] + (etiqueta(campo)[3]||"") + "' id='listado_campo_valor_" + campo + "'>" + (valor && valor.to_s != "" ? truncate(valor.to_s, :length => etiqueta(campo)[2]):"&nbsp;") + '</div>'
    end
    return cadena
  end

  # Dibuja los elementos del final del sublistado.
  def final_sublistado
      return "</fieldset>"
  end

  def icono tipo, propiedades={}
    size = propiedades[:size] == 'grande'? 32 : 16 
    image_tag("/images/iconos/" + size.to_s + "/" + tipo + ".png", :border => 0, :title => propiedades[:title] || "", :style => propiedades[:style] || '', :alt => propiedades[:title], :onmouseover => "this.src='/images/iconos/" + size.to_s + "/" + tipo + ".png';", :onmouseout => "this.src='/images/iconos/" + size.to_s + "/" + tipo + ".png';" )
  end

  def inicio_formulario url, ajax, otros={}
    if ajax
      cadena = form_remote_tag( :url => url, :html => {:id => otros[:id]||"formulario_ajax", :class => "formulario"}, :multipart => true, :loading => "Element.show('spinner'); Element.hide('botonguardar');", :complete => "Element.hide('spinner')")
      cadena << "<div class='fila' id='spinner' style='display:none'></div>"
    else
      cadena = form_tag( url, :multipart => true, :id => otros[:id]||"formulario", :class => "formulario" )
    end
    cadena << "<div class='fila'></div>\n"
    return cadena
  end

  def texto rotulo, objeto, atributo, valor=nil
    cadena = "<div class='elemento'>" + rotulo +"<br/>"
    cadena << text_field( objeto, atributo , {:class => "texto", :id => "formulario_campo_" + objeto + "_" + atributo, :type => "d", :value => valor })
    return cadena << "</div>"
  end

  def fecha rotulo, objeto, atributo, valor=nil, discards=[false, false]
    cadena = "<div class='elemento_x15'>" + rotulo + "<br/>"
    #cadena << date_select(objeto, atributo, {:discard_day=>discards[0], :discard_month=>discards[1], :order => [:day,:month,:year], :class => "texto", :id => "formulario_campo_" + objeto + "_" + atributo, :default => valor})
    otros = {}
    otros[:year_range] =  [1930, Time.now.year + 5] if  otros[:year_range].nil?
    otros[:size] = "10"
    otros[:value] = valor if valor
    cadena << calendar_date_select(objeto, atributo, otros)
    return cadena << "</div>"
  end

  def fecha_mes rotulo, objeto, atributo, valor=nil
    fecha rotulo, objeto, atributo, valor, [true,false]
  end

  def fecha_anno rotulo, objeto, atributo, valor=nil
    fecha rotulo, objeto, atributo, valor, [true,true]
  end

  def selector rotulo, objeto, atributo, valores, valor=nil, tipo=nil, vacio=nil
    cadena = "<div class='elemento_" + (tipo || "x15") + "' id='selector_" + objeto + "_" + atributo + "'>" + rotulo + "<br/>"
    if valor && valor != ""
      cadena << select(objeto, atributo, valores, {:class => "texto", :id => "formulario_campo_" + objeto + "_" + atributo, :selected => valor, :include_blank => !vacio.nil?})
    else
      cadena << select(objeto, atributo, valores, {:class => "texto", :id => "formulario_campo_" + objeto + "_" + atributo, :include_blank => !vacio.nil?})
    end
    return cadena << "</div>"
  end

  # check_box 
  def checkbox rotulo, objeto, atributo, otros={}
    if otros[:izquierda]
      '<div class="elemento">' + check_box( objeto, atributo, {:checked => otros[:checked] } ) + rotulo + '</div>'
    else
      '<div class="elemento">' + rotulo + check_box( objeto, atributo, {:checked => otros[:checked] } ) + '</div>'
    end
  end

  def final_formulario boton={}
    cadena = '<div class="fila" id="botonguardar" > <div class="elemento_derecha">'
    if boton[:submit_disabled] != true
      cadena << submit_tag( boton[:etiqueta]?boton[:etiqueta]:"Guardar", :class => "boton", :onclick => "this.disabled=true")
    end
    cadena << "</div></div>"
    cadena << "<div class='fila' id='spinner' style='display:none'></div>"
    cadena << "</FORM>"
  end

  # dibuja un mensage flash
  def mensaje cadena
    ("<div id = 'mensaje'>" + cadena + "</div>") if flash[:mensaje]
  end

  # dibuja el mensaje de error o de exito
  def mensaje_error objeto, otros={}
    if objeto.class == String
      cadena = '<div id="mensajeerror">'
      cadena << objeto
    else
      if objeto.errors.empty?
        cadena = '<div id="mensajeok">'
        cadena << "Los datos se han guardado correctamente." unless otros[:borrar]
        cadena << "Se ha eliminado correctamente." if otros[:borrar]
      else
        cadena = '<div id="mensajeerror">'
        cadena << "Se ha producido un error." + "<br>"
        objeto.errors.each {|a, m| cadena += m + "<br>" }
      end
    end
    return cadena << "</div>"
  end

  # Ventana modal (*otros para futuro uso)
  def modal( rotulo, url, titulo, otros={} )
    link_to rotulo, url, :title => titulo, :onclick => "Modalbox.show(this.href, {title: '" + titulo + "', width:820 }); return false;", :id => (otros[:id] || "")
  end

  # Ventana modal que pide confirmacion para el borrado de un elemento
  def borrado ( rotulo, url, titulo, texto, otros={} )
    # Falta añadir al titulo de la ventana modal el mismo texto superior que llevan las modales sobre la variable de session.
    cadena = '<div style="display:none;" id="'+ (otros[:id] || url[:id].to_s ) +'_borrar" class="elemento_c">'
    cadena << 'Va a eliminar:<br>' unless otros[:no_borrado]
    cadena << '<B>' + texto + '<br><br>'
    cadena << '<div class="fila"><a href="#" onclick="Modalbox.hide()"> Cancelar </a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '
    cadena << link_to( "Confirmar", url, :id => otros[:id].to_s + "_confirmar") unless otros[:ajax]
    cadena << link_to_remote( "Confirmar", :url => url, :html =>  {:id => otros[:id].to_s + "_confirmar"}) if otros[:ajax]
    cadena << '</b></div></div>'
    cadena << "<a id=\"#{ (otros[:id] || url[:id].to_s )  }\" onclick=\"Modalbox.show($('#{ (otros[:id] || url[:id].to_s )  }_borrar'), {title: '" + titulo + "', width: 600}); return false;\" href=\"#\" title='"+ url[:action].to_s + "'>"
    cadena << rotulo
    cadena << "</a>"
    return cadena
  end

  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end 

  def controlador_rotulo controlador={}
    rotulo=""
    controladores.each{|elemento| rotulo = elemento[:rotulo] if elemento[:controlador] == controlador}
    return rotulo
  end

  def controladores controlador={}
    case params[:seccion]
      when "caja"
        controladores = [ #{ :rotulo => "Pedidos", :controlador => "pedidos" },
                          { :rotulo => "Facturas Clientes" , :controlador => "factura"},
                          { :rotulo => "Clientes" , :controlador => "cliente"},
                          { :rotulo => "Entradas/Salidas de Caja" , :controlador => "caja"},
                          { :rotulo => "Ventas/Devoluciones", :controlador => "albarans" } ]
      when "productos"
        controladores = [ { :rotulo => "Facturas Proveedores", :controlador => "factura"},
                          { :rotulo => "Depósitos", :controlador => "deposito"},
                          { :rotulo => "Albaranes de entrada", :controlador => "albarans"},
                          { :rotulo => "Proveedores" , :controlador => "proveedor"},
                          { :rotulo => "Inventario", :controlador => "productos"} ]
      when "tesoreria"
        controladores = [ { :rotulo => "Informes", :controlador => "informe"},
                          { :rotulo => "Libro diario", :controlador => "libro_diario"},
                          { :rotulo => "Posicion global", :controlador => "posicion_global"},
                          { :rotulo => "Arqueo/Cierre de Caja", :controlador => "caja"},
                          { :rotulo => "Facturas de Servicios", :controlador => "factura"}  ]
      when "trueke"
        controladores = [ { :rotulo => "Cambios", :controlador => "cambio"} ]

      when "admin"
        controladores = [ #{ :rotulo => "Usuarios", :controlador => "usuarios"},
                          { :rotulo => "Backup", :controlador => "backup"},
                          #{ :rotulo => "Recuperar Objetos", :controlador => "perdidos" },
			  { :rotulo => "Parámetros", :controlador => "configuracion"},
                          { :rotulo => "Formas de Pago", :controlador => "forma_pago"},
                          { :rotulo => "Tipos de IVA", :controlador => "iva"},
                          { :rotulo => "Familias de Productos", :controlador => "familia"} ]
    end
    return controladores
  end

  def etiqueta campo
    etiqueta = {	"albaran.cliente.nombre"	=> ["Cliente", "1", 36],
			"albaran.proveedor.nombre"	=> ["Proveedor", "2_3", 36],
			"cliente.nombre"		=> ["Cliente", "1", 36],
			"familia.nombre"		=> ["Familia", "1_2", 13],
			"proveedor.nombre"		=> ["Proveedor", "1", 36],
			"codigo"			=> ["Código", "2_3", 20],
                        "codigo_mayusculas"             => ["Código", "2_3", 20],
			"producto.codigo"		=> ["Código/ISBN", "1_2", 13],
			"producto.nombre"		=> ["Nombre/Título", "1", 36],
			"producto.cantidad"		=> ["Stock", "1_5", 8, "d"],
			"producto.autor"		=> ["Autor", "2_3", 20],
			"nombre_producto"		=> ["Nombre/Título", "1", 36],
			"nombre"			=> ["Nombre/Título", "1", 36],
			"autor"				=> ["Autor", "2_3", 20],
			"producto.precio"		=> ["PVP", "1_3", 14, "f"],
			"cantidad"			=> ["Cant.", "1_5", 8, "d"],
			"precio"			=> ["PVP", "1_3", 14, "f"],
			"subtotal"			=> ["Subtotal", "1_3", 14, "f"],
			"descuento"			=> ["% Dto.", "1_5", 8, "d"],
			"producto.familia.iva.valor"	=> ["% IVA", "1_5", 8, "d"],
			"iva.nombre"			=> ["IVA aplicado", "1", 36],
			"iva"				=> ["% IVA", "1_5", 8, "d"],
			"iva_aplicado"			=> ["IVA", "1_3", 14, "f"],
			"precio_compra"			=> ["P.Prov.", "1_3", 14, "f"],
			"precio_venta"			=> ["PVP", "1_3", 14, "f"],
			"total"				=> ["Total", "1_3", 14, "f"],
			"forma_pago.nombre"		=> ["Forma de Pago", "1", 36],
			"factura.codigo"		=> ["Código de Factura", "2_3", 20],
			"albaran.factura.codigo"	=> ["Código de Factura", "2_3", 20],
			"albaran.factura.fecha"		=> ["Fecha", "1_2", 13],
			"albaran.codigo"		=> ["Código de Albarán", "2_3", 20],
			"albaran.fecha"			=> ["Fecha", "1_2", 13],
			"fecha_devolucion"		=> ["Devolución", "1_2", 13],
			"albaran.fecha_devolucion"	=> ["Devolución", "1_2", 13],
			"email"				=> ["Email", "2_3", 20],
			"nombre_param"			=> ["Parámetro","1", 36],
			"valor_param"			=> ["Valor", "1", 36],
			"base_imponible"		=> ["Base Imp.", "1_3", 14, "f"],
			"valor_iva"			=> ["% IVA", "1_5", 8, "d"],
			"valor_irpf"			=> ["% IRPF", "1_5", 8, "d"],
			"acumulable"			=> ["% Reemb.", "1_3", 14, "d"],
			"importe"			=> ["Importe", "1_3", 14, "f"],
			"concepto"			=> ["Concepto", "1", 36],
			"debe"				=> ["Debe", "1_3", 14, "f"],
			"haber"				=> ["Haber", "1_3", 14, "f"],
			"fecha_hora"			=> ["Fecha", "2_3", 20],
			"comentarios"			=> ["Observaciones", "1", 36],
                        "ventas"			=> ["Ventas", "2_3", 20, "f"],
			"compras"			=> ["Compras", "2_3", 20, "f"],
			"pagos_servicios"		=> ["Otros Gastos", "2_3", 20, "f"],
			"entradas/salidas"		=> ["Entradas/Salidas", "2_3", 20, "f"],
			"total caja"			=> ["Total Caja", "2_3", 20, "f"],
                        "credito"			=> ["Crédito", "1_3", 14, "f"],
			"credito_acumulado"		=> ["Acumulado", "1_3", 14, "f"],
		}
    return etiqueta[campo] || [campo.capitalize, "1_2", 13]
  end

end
