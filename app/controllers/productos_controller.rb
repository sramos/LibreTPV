class ProductosController < ApplicationController

  require 'json'

  def index
    session[("productos_filtrado").to_sym] = ""
    redirect_to :action => :listado
  end

  def filtrado
    session[("productos_filtrado_tipo").to_sym] = params[:filtro][:tipo] if params[:filtro]
    session[("productos_filtrado_valor").to_sym] = ( params[:filtro] && params[:filtro][:valor] != "" ) ? params[:filtro][:valor] :nil 
    session[("productos_filtrado_condicion").to_sym] = params[:filtro] ? params[:filtro][:condicion] : nil 
    redirect_to :action => :listado
  end

  def listado
    #@campos_filtro = [["Nombre","nombre"], ["Autor","autor"], ["Codigo","codigo"] ,["Editor","editor"], ["Familia","familias.nombre"], ["Proveedor","proveedores.nombre"]]
    @campos_filtro = [["Nombre","nombre"], ["Autor","autor"], ["Cantidad","cantidad"], ["Codigo","codigo"] ,["Editor","editor"], ["Familia","familias.nombre"]]
    paginado = Configuracion.valor('PAGINADO')

    if session[("productos_filtrado_tipo").to_sym] && session[("productos_filtrado_valor").to_sym]
      if session[("productos_filtrado_tipo").to_sym] =~ /familias.nombre/
        @productos = Producto.paginate :page => params[:page], :per_page => paginado, 
		:order => 'nombre ASC',
                :include => [ :familia ],             
                :conditions => [ session[("productos_filtrado_tipo").to_sym] + ' LIKE ?', "%" + session[("productos_filtrado_valor").to_sym] + "%" ]
      elsif session[("productos_filtrado_tipo").to_sym] =~ /cantidad/
        @productos = Producto.paginate :page => params[:page], :per_page => paginado,
		:order => 'nombre ASC',
                :conditions => [ session[("productos_filtrado_tipo").to_sym] + ' ' + session[("productos_filtrado_condicion").to_sym] + ' ?', session[("productos_filtrado_valor").to_sym].to_i ]
      elsif session[("productos_filtrado_tipo").to_sym] =~ /proveedores.nombre/
        @productos = Producto.paginate :page => params[:page], :per_page => paginado,
		:order => 'nombre ASC'
      else
        @productos = Producto.paginate :page => params[:page], :per_page => paginado,
		:order => 'nombre ASC',
		:conditions => [ session[("productos_filtrado_tipo").to_sym] + ' LIKE ?', "%" + session[("productos_filtrado_valor").to_sym] + "%" ]
      end
    else
      @productos = Producto.paginate :page => params[:page], :per_page => paginado, :order => 'nombre'
    end
  end

  def editar
    @familias = Familia.all
    if params[:codigo]
      @producto = producto_x_codigo_isbn_con_imagen(params[:codigo])
    else
      @producto = params[:id]?Producto.find(params[:id]) : nil
    end
    @producto_familia_id = @producto.familia_id if ! @producto.nil?
    if params[:inventario]
      render :partial => "formulario"
    else
      render :partial => "propiedades"
    end
  end

  def modificar
    @producto = params[:id] ?  Producto.find(params[:id]) : Producto.new
    @producto.update_attributes params[:producto]
    if params[:inventario]
      flash[:error] = @producto 
      redirect_to :action => :listado
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
    @producto = Producto.find(params[:id])
    @producto.destroy
    flash[:error] = @producto
    redirect_to :action => :listado
  end

  def cambio_familia
    @producto = params[:id] ? Producto.find(params[:id]) : nil 
    @producto.familia.id = params[:producto_familia_id]
    @producto_familia_id = params[:producto_familia_id]
    @familias = Familia.all

    render :partial => "propiedades"
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
    lineas = AlbaranLinea.find :all, :conditions=>{:producto_id => params[:id]}
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
      @producto = producto_x_codigo_isbn(params[:codigo])
      render :partial => params[:template]
    end
  end

  private
    def producto_x_codigo_isbn isbn
      producto = Producto.new
      output = Net::HTTP.get('books.google.com', '/books/download/libro.ris?vid=' + isbn + '&output=ris').split("\r\n")
      propiedades={}
      output.each{|a|
        a=~ /^([\S]{2})\s+-\s+(.+)$/
        propiedades[$1]? propiedades[$1] += " - " + $2 : propiedades[$1] = $2
      }
      if propiedades["SN"]
        producto.nombre = propiedades["T1"]
        producto.autor = propiedades["A1"]
        producto.anno = propiedades["Y1"]
        producto.editor = propiedades["PB"]
        producto.familia_id = 1
      end
      producto.codigo = params[:codigo]
  
      return producto
    end

  def producto_x_codigo_isbn_con_imagen isbn
    producto = producto_x_codigo_isbn isbn
    data = Net::HTTP.get('books.google.com','/books?jscmd=viewapi&bibkeys=ISBN:' + isbn)
    data =~ /^var _GBSBookInfo = (.+);$/
    if $1
      result = JSON.parse($1)

      # if the hash has 'Error' as a key, we raise an error
      if result.has_key? 'Error'
        raise "web service error"
      end

      producto.url_imagen = result['ISBN:'+isbn]['thumbnail_url'].to_s.gsub(/zoom=5/, 'zoom=1') if producto && result['ISBN:'+isbn]
    end
    return producto
  end

  def libro_x_isbn_google
    #isbn = "9788467426373"
    @producto = params[:id] ? Producto.find(params[:id]) : Producto.new
    @familias = Familia.all
    isbn = params[:codigo]

    # en JSON
    #http://books.google.com/books?jscmd=viewapi&bibkeys=ISBN:
    # y devuelve tambien la referencia a la portada del libro
    refman = { "T1" => "Titulo", "A1" => "Autor", "Y1" => "Año", "PB" => "Editor", "T3" => "Coleccion", "UR" => "URL", "SN" => "ISBN" }

    output = Net::HTTP.get('books.google.com', '/books/download/libro.ris?vid=' + isbn + '&output=ris').split("\r\n")
    @propiedades={} 
    output.each{|a|
      a=~ /^([\S]{2})\s+-\s+(.+)$/
      @propiedades[$1]? @propiedades[$1] += " - " + $2 : @propiedades[$1] = $2
    }
    if @propiedades["SN"]
      @producto.nombre = @propiedades["T1"]
      @producto.autor = @propiedades["A1"]
      @producto.anno = @propiedades["Y1"] 
      @producto.editor = @propiedades["PB"]
      @producto.familia_id = 1
    end
    @producto.codigo = params[:codigo] 
    render :partial => "propiedades"
  end

  def libro_x_isbn_mcu
    isbn = "9788467426373"
    # http://catalogo.bne.es/uhtbin/webcat
    url = URI.parse('http://www.mcu.es/webISBN/tituloSimpleDispatch.do')
    post_params = {	'layout'	=> 'busquedaisbn',
			'language'	=> 'es',
			'params.cisbnExt' => isbn }

    resp, data = Net::HTTP.post_form(url, post_params)
  end

# Z3950

# 9788499182254
#
# Ministerio de cultura
#  Host: rebeca.mcu.es
#  Port: 210
#  Database: absysrebeca
#  Syntax: IBERMAC
#
# Biblioteca Nacional
#  Host: sigb.bne.es 
#  Port: 2200
#  Database: Unicorn / bimo
#  Syntax: IBERMAC / USMARC
#
# Biblioteca del Congreso
#  Host: z3950.loc.gov
#  Port: 7090
#  Database: Voyager
#  Syntax: USMARC
#
#  >> ZOOM::Connection.open('z3950.loc.gov', 7090) do |conn|
#  ?> conn.database_name = 'Voyager'
#  >> conn.preferred_record_syntax = 'USMARC'
#  >> rset = conn.search('@attr 1=7 0253333490')
#  >> p rset[0]
#  >> end
# 01109cam  2200277 a 4500
# 001 708964
# 005 19980710092633.8
# 008 970604s1997    inuab    b    001 0 eng
# 035    $9 (DLC)   97023698
# 906    $a 7 $b cbc $c orignew $d 1 $e ocip $f 19 $g y-gencatlg 
# 955    $a pc16 to ja00 06-04-97; jd25 06-05-97; jd99 06-05-97; jd11 06-06-97;aa05 06-10-97; CIP ver. pv08 11-05-97
# 010    $a    97023698 
# 020    $a 0253333490 (alk. paper)
# 040    $a DLC $c DLC $d DLC
# 050 00 $a QE862.D5 $b C697 1997
# 082 00 $a 567.9 $2 21
# 245 04 $a The complete dinosaur / $c edited by James O. Farlow and M.K. Brett-Surman ; art editor, Robert F. Walters.
# 260    $a Bloomington : $b Indiana University Press, $c c1997.
# 300    $a xi, 752 p. : $b ill. (some col.), maps ; $c 26 cm.
# 504    $a Includes bibliographical references and index.
# 650  0 $a Dinosaurs.
# 700 1  $a Farlow, James Orville.
# 700 2  $a Brett-Surman, M. K., $d 1950-
# 920    $a **LC HAS REQ'D # OF SHELF COPIES**
# 991    $b c-GenColl $h QE862.D5 $i C697 1997 $t Copy 1 $w BOOKS
# 991    $b r-SciRR $h QE862.D5 $i C697 1997 $t Copy 1 $w GenBib bi 98-003434
#
# $ yaz-client
# Z> open tcp:sigb.bne.es:2200/bimo
#Connecting...OK.
#Sent initrequest.
#Connection accepted by v3 target.
#ID     : Unicorn GL3.1 Bath
#Name   : SIRSI Corporation
#Version: 3.0
#Options: search present delSet scan sort namedResultSets
#Elapsed: 0.551236
#Z> find @attr 1=7 8435003906
#Sent searchRequest.
#Received SearchResponse.
#Search was a success.
#Number of hits: 1, setno 1
#records returned: 0
#Elapsed: 0.083688
#Z> show 1
#Sent presentRequest (1+1).
#Records: 1
#[BIMO]Record type: USmarc
#(Length implementation at offset 22 should hold a digit. Assuming 0)
#01149namaa2200301 b 4500
#001 Mimo0000964332
#005 20080212        
#008 980807s1983    esp|          ||| ||spa  
#016 7  $a bimoBNE19982105873 $2 SpMaBN
#017    $a B 1701-1983
#020    $a 84-350-0390-6
#040    $a SpMaBN $b spa $c SpMaBN $e rdc
#080  0 $a 929 Vidal, Gore (049.3)
#245 10 $a Conversaciones con Gore Vidal $h [Texto impreso] $c Robert J. Stanton y Gore Vidal, eds. ; selección e introducción de Robert J. Stanton ; [traducción del inglés de Horacio Vázquez Rial]
#260 0  $a Barcelona $b Edhasa $c 1983
#300    $a 364 p. $c 19 cm
#500    $a Índice
#600 17 $a Vidal, Gore $d 1925- $v Entrevistas $2 embne
#700 11 $a Vidal, Gore $d 1925-
#956    $a 1 2
#980    $. 852. 40 $a M-BN $b BNMADRID $9 MO01181437 $j 4/207063 $x DG $c SG_RECOLET
#980    $. 852. 40 $a M-BN $b BNALCALA $9 MO01181438 $j DL/222835 $x DG $c CONSERVACI
#926    $a BNMADRID $b SG_RECOLET $c 4/207063 $d FONDO_MODE $f 1
#926    $a BNALCALA $b CONSERVACI $c DL/222835 $d NO_PRESTA $f 1
#927    $a BNALCALA
#927    $b $<hld_usmarc_852v1> $c DL/222835
#927    $a BNMADRID
#927    $b $<hld_usmarc_852v1> $c 4/207063
#
#nextResultSetPosition = 2
#Elapsed: 0.867225

end
