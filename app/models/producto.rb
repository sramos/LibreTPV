# encoding: UTF-8
#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2013 Santiago Ramos <sramos@sitiodistinto.net> 
#
#    Este programa es software libre: usted puede redistribuirlo y/o modificarlo 
#    bajo los términos de la Licencia Pública General GNU publicada 
#    por la Fundación para el Software Libre, ya sea la versión 3 
#    de la Licencia, o (a su elección) cualquier versión posterior.
#
#    Este programa se distribuye con la esperanza de que sea útil, pero 
#    SIN GARANTÍA ALGUNA; ni siquiera la garantía implícita 
#    MERCANTIL o de APTITUD PARA UN PROPÓSITO DETERMINADO. 
#    Consulte los detalles de la Licencia Pública General GNU para obtener 
#    una información más detallada. 
#
#    Debería haber recibido una copia de la Licencia Pública General GNU 
#    junto a este programa. 
#    En caso contrario, consulte <http://www.gnu.org/licenses/>.
#################################################################################
#
#++


class Producto < ActiveRecord::Base

  # Definimos la imagen por defecto a utilizar
  DEFAULT_IMAGE_URL = '/cover/missing_cover.jpg'

  validates_presence_of :nombre, :codigo
  #validates_numericality_of :precio, :cantidad
#  validates_format_of :url_imagen,
#	:with => %r{\.(gif|jpg|png)$}i,
#	:message => 'debe ser una URL de GIF, JPG ' +
#	'o PNG.(gif|jpg|png)'
  validates_numericality_of :precio, :greater_than => 0, :message => "El producto tiene que tener un precio de venta."

  belongs_to :familia
  belongs_to :materia
  belongs_to :editorial
  has_many :albaran_linea
  has_one :relacion_web, as: :elemento

  has_many :autor_x_producto, dependent: :destroy
  has_many :autor, through: :autor_x_producto

  after_save :actualiza_editorial, :actualiza_autores, :actualiza_imagen
  after_destroy :eliminar_relacion_web

  # Imagen asociada al producto
  #attr_accessible :imagen
  has_attached_file :imagen,
    path: "public/cover/:id.:extension",
    url: "/cover/:id.:extension",
    default_url: DEFAULT_IMAGE_URL 
  validates_attachment_content_type :imagen, content_type: /\Aimage\/.*\Z/, :message => "La imagen de portada no es válida."


  # Creamos un attr_writer para guardar en @editor el valor (y luego relacionarlo con el modelo)=
  attr_writer :editor

  # Devuelve el string del editor asociado (no usamos el attr_reader para poder pillar el valor del modelo asociado)
  def editor
    @editor || (editorial ? editorial.nombre : nil)
  end

  # Creamos un attr_writer para guardar en @autores el valor (y luego relacionarlo con los modelos)
  attr_writer :autores

  # Devuelve un string con los nombres de todos los autores
  def autores
    @autores || self.autor.collect{|a| a.nombre}.join(' / ')
  end

  def get_remote_data
    if self.codigo
      data = get_data_from_google || get_data_from_todostuslibros
      self.url_imagen = data[:image] if data && data[:image]
      self.descripcion = data[:description] if data && data[:description] 
    end
  end

  def get_remote_image
    data = get_data_from_lcdl
    data = get_data_from_google unless data && data[:image]
    data = get_data_from_todostuslibros unless data && data[:image]
    self.url_imagen = data[:image] if data && data[:image]
  end

  def get_available_images
    # Primero metemos "Ninguna" imagen
    images = {"Ninguna" => DEFAULT_IMAGE_URL}
    # Mete las imagenes disponibles en sitios externos
    data = get_data_from_lcdl
    images["LCDL"] = data[:image] if data && data[:image]
    data = get_data_from_google
    images["Google Books"] = data[:image] if data && data[:image]
    data = get_data_from_todostuslibros
    images["TTL"] = data[:image] if data && data[:image]
    # La propia subida si existe
    images["Actual"] = self.imagen if self.imagen_file_name
    return images
  end

  def get_remote_description
    data = get_data_from_google
    data = get_data_from_todostuslibros unless data && data[:description]
    self.descripcion = data[:description] if data && data[:description]
  end

private

  # Actualiza la imagen a usar como cover
  def actualiza_imagen
    # Si se esta utilizando una imagen externa, la descarga a local
    if Producto.column_names.include?("imagen_path") && !self.url_imagen.blank? && (self.imagen.blank? || self.url_imagen != self.imagen.to_s)
      puts "------> (" + (self.id||"NEW").to_s + ") Descargando la imagen remota: " + url_imagen
      # Desactivamos el propio callback
      Producto.skip_callback :save, :after, :actualiza_imagen
      # Metemos la descarga en un try-catch para que se active el callback de nuevo en caso de error
      # y solo lo invocamos cuando exista el campo para contenerlo (para evitar que haya descargas antes de que se haya completado la migracion)
      begin
        self.imagen = open(url_imagen)
        self.save
      rescue
        logger.error "----------------> ERRORES descargando la imagen " + url_imagen.to_s
      end if Producto.column_names.include?("imagen_file_name")
      # Activamos de nuevo el callback
      Producto.set_callback :save, :after, :actualiza_imagen
    end
    # En cualquier caso, al terminar pone siempre a nil url_imagen si tenemos imagen bien subida
    self.update_column(:url_imagen, nil) unless self.url_imagen.blank? && self.imagen.blank?
  end

  # Actualiza la relacion con la editorial
  def actualiza_editorial
    ed_id = @editor.nil? ? nil : Editorial.find_or_create_by_nombre(@editor.strip).id
    self.update_column(:editorial_id, ed_id) unless ed_id == self.editorial_id
  end

  # Actualiza las relaciones con los autores
  def actualiza_autores
    # Primero limpiamos todo a no ser que no hayamos tocado el campo @autores
    self.autor_x_producto.destroy_all unless @autores.nil?
    if @autores
      # Separamos los autores por "/"
      @autores.strip.mb_chars.upcase.split(%r{\s*/\s*}).each do |str_autor|
        # Genera el autor corrigiendo previamente el nombre:
        #  * Varios espacios se convierten en uno solo
        #  * Se eliminan espacios antes de la coma (separacion de apellido del nombre) 
        nom = str_autor.gsub(/\s+,\s./, ', ').gsub(/\s+/, ' ')
        aut = Autor.find_or_create_by_nombre nom
        axp = AutorXProducto.create(autor_id: aut.id, producto_id: self.id) if aut.errors.empty?
      end  
    end
  end

  # Marca el campo "eliminar" de la tabla de relaciones como true
  def eliminar_relacion_web
    relacion_web.update_attribute(:eliminar, true) if self.relacion_web
  end

  def get_data_from_google
    return_data = nil
    search = '/books?q=isbn%3A' + self.codigo 

    logger.info  "-----------------> Buscando en GOOGLE: " + search
    begin
      data = Net::HTTP.get('books.google.com',search)
      #puts "-------------> Buscamos el enlace"
      enlace = Hpricot(data).search("//h2[@class='resbdy']//a").first if data
      #puts "-------------> OHHHHH!!!!: " + data.inspect if data && !enlace
      #puts "--------------> No hay enlace al libro " + self.title + " (no existe en su BBDD?)" if data && !enlace
      if enlace
        #puts "-------> Tenemos el enlace... vamos a pedirlo " + enlace[:href]
        enlace = enlace[:href].sub(/http:\/\/books.google.com/,"")
        doc = Net::HTTP.get('books.google.com', enlace + "&redir_esc=y")
        #puts "-------> " + enlace + "&redir_esc=y"
        #puts "-------> DATA -------> " + doc
        remote_image = Hpricot(doc).search("//div[@class='bookcover']//img").first
        remote_description = Hpricot(doc).search("//div[@id='synopsistext']//p").first
        #puts "-------------- IMAGEN"
        #puts "--------------> " + remote_image[:src] if remote_image
        #puts "-------------- IMAGEN"
        if (remote_image && remote_image[:src] && remote_image[:src] != "/googlebooks/images/no_cover_thumb.gif")
          return_data = Hash.new
          return_data[:image] = remote_image[:src] if remote_image
          return_data[:description] = remote_description.inner_html if remote_description && remote_description.inner_html && remote_description.inner_html != "Unknown"
        end
      end
    rescue
      logger.info "-----------------> GOOGLE: Error obteniendo informacion del libro"
    end
    return return_data
  end

  def get_data_from_todostuslibros
    return_data = nil
    host = 'www.todostuslibros.com'
    search = '/busquedas/?keyword=' + self.codigo

    logger.info  "-----------------> Buscando en TTL: " + search
    begin
      data = Net::HTTP.get(host, search)
      enlace = Hpricot(data).search("//div[@class='details']//h2//a").first if data
      if enlace
        doc = Net::HTTP.get(host, enlace[:href] )
        remote_images = Hpricot(doc).search("//img[@class='portada']")
        remote_description = Hpricot(doc).search("//p[@itemprop='description']").first.inner_html
        remote_image = nil
        remote_images.each do |ri|
          #puts "----------> Revisando la imagen remota " + ri[:src] if ri && ri[:src]
          remote_image = ri[:src] if remote_image.nil? && ri && ri[:src] && ri[:src] != "/img/nodisponible.gif"
        end
        #puts "---------------------- IMAGEN "
        #puts "---------------------> " + remote_image if remote_image
        #puts "---------------------- IMAGEN "
        if (remote_image || remote_description)
          return_data = Hash.new
          return_data[:image] = remote_image if remote_image && remote_image != ""
          return_data[:description] = remote_description if remote_description
        end
      end
    rescue
      logger.info "-----------------> TTL: Error obteniendo informacion del libro"
    end
    return return_data
  end

  def get_data_from_lcdl
    return_data = nil
    host = 'www.casadellibro.com'
    search = '/busqueda-generica?busqueda=isbn%3A' + self.codigo

    logger.info  "-----------------> Buscando en LCDL: " + search
    begin
      data = Net::HTTP.get(host, search)
      enlace = Hpricot(data).search("//div[@class='list-pag']//div//div[@class='mod-list-item']//div[@class='txt']//a").first if data
      if enlace
        doc = Net::HTTP.get(host, enlace[:href])
        remote_image = Hpricot(doc).search("//img[@id='imgPrincipal']").first
        return_data = {image: remote_image[:src]} if remote_image
      end
    rescue
      logger.info "-----------------> LCDL: Error obteniendo informacion del libro"
    end
    return return_data
  end

end
