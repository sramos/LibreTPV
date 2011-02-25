class ProductosController < ApplicationController

  def index
    flash[:mensaje] = "Listado de Productos"
    redirect_to :action => :listado
  end

  def listado
    @productos = Producto.all
  end

  def editar
    @producto = params[:id] ?  Producto.find(params[:id]) : nil
    @producto_familia_id = params[:id] ? @producto.familia.id : nil
    @familias = Familia.all
  end

  def modificar
    @producto = params[:id] ?  Producto.find(params[:id]) : Producto.new
    @producto.update_attributes params[:producto]
    flash[:error] = @producto
    redirect_to :action => :listado
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

  def libro_x_isbn_google
    #isbn = "9788467426373"
    @producto = params[:id] ? Producto.find(params[:id]) : Producto.new
    @familias = Familia.all
    isbn = params[:codigo]

    # en JSON
    #http://books.google.com/books?jscmd=viewapi&bibkeys=ISBN:
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
    
    render :partial => "propiedades"
    #render "editar"
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
