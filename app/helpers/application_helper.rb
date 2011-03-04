# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


  def cabecera_listado campos
    @campos_listado = campos
    cadena = "<div class='listado'><div class='listadocabecera'>"
    for campo in campos
      cadena += "<div class='listado_campo'>" + campo.capitalize + "</div>"
    end
    cadena += "<div class='listado_derecha'>"
    cadena += link_to icono('Plus',{:title => "Nuevo"}), {:action => 'editar'}
    cadena += "</div></div>"
    return cadena
  end

  def fila_listado objeto
    cadena = ""
    for campo in @campos_listado
      valor=objeto
      campo.split('.').each { |metodo| valor = valor.send(metodo) if valor }
      cadena += "<div class='listado_campo' id='listado_campo_" + campo + "'>" + valor.to_s + '</div>'
    end
    #cadena += "</div>"
    return cadena
  end

  def final_listado objeto
    cadena = "</div>"
    return cadena
  end

  def cabecera_sublistado rotulo, campos, sub_id
    @campos_sublistado = campos     
    script = "document.getElementById('" +  sub_id + "').innerHTML=\"\";" if sub_id
    cadena = '<br><fieldset class="sublistado"> <legend>'+ rotulo +'</legend>'
    cadena << '<div class="linea"><div class="listado_derecha" id="cerrarsublistado">'
    cadena << link_to_function( icono('Cancel',{:Title => "Ocultar"}), script, {:id => sub_id + "_ocultar_sublistado"} ) if sub_id
    cadena << "</div></div><br/><br/><div class='listadocabecera'>"
    for campo in campos
      cadena << "<div class='listado_campo'>" + campo.capitalize + "</div>"
    end
    cadena << '</div>'
  end

  def fila_sublistado objeto
    cadena = ""
    for campo in @campos_sublistado
      valor=objeto
      campo.split('.').each { |metodo| valor = valor.send(metodo) if valor }
      cadena += "<div class='listado_campo' id='listado_campo_" + campo + "'>" + valor.to_s + '</div>'
    end
    return cadena
  end

  # Dibuja los elementos del final del sublistado.
  def final_sublistado
      return "</fieldset>"
  end

  def icono tipo, propiedades={} 
    image_tag("/images/iconos/16/" + tipo + ".png", :border => 0, :title => propiedades[:title] || "", :alt => propiedades[:title], :onmouseover => "this.src='/images/iconos/16/" + tipo + ".png';", :onmouseout => "this.src='/images/iconos/16/" + tipo + ".png';" )
  end

  def inicio_formulario url, ajax, otros={}
    if ajax
      #cadena = form_remote_tag( :url => url, :html => {:id => "formulario_ajax", :class => "formulario"}, :multipart => true, :before => "tinyMCE.triggerSave(true, true);", :loading => "Element.show('spinner'); Element.hide('botonguardar');", :complete => "Element.hide('spinner')")
      cadena = form_remote_tag :url => url 
    else
      cadena = form_tag( url, :multipart => true, :id => "formulario", :class => "formulario" )
    end
    cadena << "<div class='fila' id='spinner' style='display:none'></div>"
    cadena << "<div class='fila'></div>\n"
    return cadena
  end

  def texto rotulo, objeto, atributo, valor=nil
    cadena = "<div class='elemento'>" + rotulo +"<br/>"
    cadena << text_field( objeto, atributo , {:class => "texto", :id => "formulario_campo_" + atributo, :type => "d", :value => valor })
    return cadena << "</div>"
  end

  def final_formulario boton={}
    cadena = '<div class="fila" id="botonguardar" > <div class="elemento_derecha">'
    if boton[:submit_disabled] != true
      cadena << submit_tag( "Guardar", :class => "boton", :onclick => "this.disabled=true")
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

  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end 

end
