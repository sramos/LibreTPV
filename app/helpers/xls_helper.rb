# Methods added to this helper will be available to all templates in the application.
module XlsHelper

  #--
  # METODOS PARA SALIDAS XLS
  #--

  def formato_xls_negrita
    return Spreadsheet::Format.new :weight => :bold, :align => :top, :text_wrap => true, :number_format => '#,##0.00'
  end
  def formato_xls_negrita_centrado
    return Spreadsheet::Format.new :weight => :bold, :align => :top, :text_wrap => true, :number_format => '#,##0.00', :horizontal_align=>:center
  end
  def formato_xls_normal
    return Spreadsheet::Format.new :text_wrap => true, :align => :top, :number_format => '#,##0.00'
  end
  def formato_xls_cabecera
    return Spreadsheet::Format.new :weight => :bold, :align => :middle, :pattern => 1, :pattern_fg_color => :aqua
  end
  def formato_xls_centrado_resaltado
    return Spreadsheet::Format.new :text_wrap => true, :align => :middle, :number_format => '#,##0.00', :horizontal_align=>:center, :pattern => 1, :pattern_fg_color => :silver
  end

  # Construye la salida de un listado
  def crea_hoja_xls workbook, subhoja=nil
    # Recoge los datos segun de donde vengan
    if (subhoja)  
      _objetos = subhoja[:objetos]
      _subobjetos = subhoja[:subobjetos]
      _titulo = subhoja[:titulo]
      _cabecera = subhoja[:cabecera]
      _tipo = subhoja[:tipo]
      _filtrado = subhoja[:filtrado] 
      _ordenado = subhoja[:ordenado]
      _ordenado_asc_desc = subhoja[:ordenado_asc_desc]
    else
      _objetos = @objetos
      _subobjetos = @subobjetos
      _titulo = @xls_title || params[:controller].capitalize
      _cabecera = @xls_head || (params[:seccion].capitalize + " - " + params[:controller].capitalize + (params[:action] == "index" ? "" : " - " + params[:action].capitalize))
      _tipo = @tipo
      _filtrado = @estado_filtrado
      _ordenado = session[(params[:controller]+"_cadena_orden").to_sym]
      _ordenado_asc_desc = session[(params[:controller]+"_asc_desc").to_sym]
    end 

    hoja = workbook.create_worksheet
    hoja.name = _titulo 

    hoja.default_format = formato_xls_normal
    hoja.row(0).default_format = formato_xls_cabecera
    hoja.row(0).height = 25
    hoja[0,0] = _cabecera

    fila = 1
    # Los campos a sacar son los del listado + los de la informacion adicional
    campos = campos_listado(_tipo) 
    campos += campos_info(_tipo) if campos_info(_tipo)

    # Mete la línea de filtrado
    if _filtrado 
      filtrado_por = _("Filtrado por: ")
      _filtrado.each do |filtro|
        filtrado_por += filtro + " | "
      end
      hoja[fila,0] = filtrado_por
      hoja.row(fila).default_format = formato_xls_cabecera
      fila +=1
    end

    # Mete la línea de ordenado
    if _ordenado 
      nombre_campo = _ordenado 
      campos.each { |campo| nombre_campo = campo[0] if campo[2] == _ordenado }
      ordenado_por = _("Ordenado por: ") + nombre_campo.capitalize
      ordenado_por += " (" + _ordenado_asc_desc.downcase + ")" if _ordenado_asc_desc
      hoja[fila,0] = ordenado_por
      hoja.row(fila).default_format = formato_xls_cabecera
      fila +=1
    end

    # Mete las cabeceras de los campos 
    columna=0
    fila += 1
    hoja.row(fila).default_format = formato_xls_negrita
    campos.each do |cmp|
      campo = etiqueta(cmp)
      hoja[fila,columna] = (campo[0]=="&nbsp;" ? "" : campo[0])
      hoja.column(columna).width = campo[2]
      columna += 1; 
    end
    # Mete las cabeceras de los campos de objetos dependientes
    _subobjetos.each do |subobjeto|
      campos_listado(subobjeto).each do |cmp|
        campo = etiqueta(cmp)
        hoja[fila,columna] = (etiqueta[0]=="&nbsp;" ? "" : (campo[0] + " " + subobjeto.tr("_", " ").capitalize) )
        hoja.column(columna).width = campo[2]
        columna += 1;
      end
    end if _subobjetos

    fila += 1

    # Mete cada uno de los elementos proporcionados
    _objetos.each do |objeto|
      columna = 0
      fila_incremento = 1
      # Mete los campos del objeto que hay en el listado
      campos.each do |cmp|
        campo = etiqueta(cmp) 
        #valor = objeto
        #cmp.split('.').each do |metodo|
        #  valor = (metodo =~ /(\S+)\s(\S+)/ ? valor.send($1,$2) : valor.send(metodo)) if valor
        #end
        valor = obtiene_valor_campo objeto, cmp
        valor_real = ""
        if valor.class.to_s == "Array"
          saltos = 0
          valor.each do |v|
            valor_real += (valor_real=="" ? "" : "\n\r") + v
            saltos += 1
          end
          altura = 12 * saltos
        else
          valor_real = valor
          altura = 13 * (1 + valor_real.to_s.size/campo[2].to_i)
        end
        hoja[fila,columna] = valor_real
        hoja.row(fila).height = altura if altura > hoja.row(fila).height
        columna += 1
      end
      # Mete los campos de los subobjetos dependientes 
      _subobjetos.each do |subobjeto|
        elementos = objeto.send(subobjeto) 
        fila_elemento = 0 
        columna_elemento = columna
        # Recorre cada resultado del subobjeto relacionado
        elementos.each do |elemento|
          columna_elemento = columna 
          # Y va dibujando cada campo
          campos_listado(subobjeto).each do |cmp|
            campo = etiqueta(cmp)
            #valor = elemento 
            #cmp.split('.').each do |metodo|
            #  valor = (metodo =~ /(\S+)\s(\S+)/ ? valor.send($1,$2) : valor.send(metodo)) if valor
            #end
            valor = obtiene_valor_campo elemento, cmp
            hoja[fila_elemento+fila,columna_elemento] = valor
            altura = 13 * (1 + valor.to_s.size/campo[2].to_i)
            hoja.row(fila_elemento+fila).height = altura if altura > hoja.row(fila).height
            columna_elemento += 1
          end
          fila_elemento += 1
        end
        # Ajusta la columna y el incremento maximo que ha habido en filas
        columna = columna_elemento
        fila_incremento = fila_elemento if fila_elemento > fila_incremento 
      end if _subobjetos
      # Ajusta las filas segun el incremento maximo 
      fila += fila_incremento 
      # Crea la subhoja si existe (y solo si no esta redirigido)
      if @subhoja && subhoja.nil?
        _subhoja = @subhoja.clone
        _subhoja[:titulo] = obtiene_valor_campo objeto, @subhoja[:titulo]
        _subhoja[:cabecera] = @subhoja[:cabecera] + " " + _subhoja[:titulo]
        _subhoja[:objetos] = obtiene_valor_campo objeto, @subhoja[:objetos]
        crea_hoja_xls workbook, _subhoja
      end
    end
  end

end
