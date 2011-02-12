# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper


def cabecera_listado campos
  @campos_listado = campos
  cadena = "<div class='listado'>"
  for campo in campos
    cadena += '<div class="cabecera_listado">' + campo + ' </div>'
  end
  cadena += "<ul>"
  return cadena
end

def fila_listado objeto
  cadena = "<li>"
  for campo in @campos_listado
    cadena += '<div class="campo_listado">' + objeto.send(campo) + '</div>' if objeto.send(campo)
  end
  cadena += "</li>"
  return cadena
end

def final_listado objeto
  cadena = "</ul></div>"
  return cadena
end


end
