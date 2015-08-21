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

  after_save :actualiza_editorial
  after_destroy :eliminar_relacion_web

  # Creamos un attr_writer para guardar en @editor el valor
  attr_writer :editor

  # Devuelve el string del editor asociado (no usamos el attr_reader para poder pillar el valor del modelo asociado)
  def editor
    @editor || (editorial ? editorial.nombre : nil)
  end

  # Sincroniza con la BBDD de la web
  def sincroniza_drupal
    # Solo sincroniza si esta definida la conexion con la BBDD
    if Rails.application.config.database_configuration["drupal_#{Rails.env}"]
      # Hace falta una tabla de conversion NID <-> ID
    end
  end

  def get_remote_data
    if self.codigo
      data = get_data_from_google || get_data_from_todostuslibros
      self.url_imagen = data[:image] if data && data[:image]
      self.descripcion = data[:description] if data && data[:description] 
    end
  end

  def get_remote_image
    data = get_data_from_google
    data = get_data_from_todostuslibros unless data && data[:image]
    self.url_imagen = data[:image] if data && data[:image]
  end

  def get_remote_description
    data = get_data_from_google
    data = get_data_from_todostuslibros unless data && data[:description]
    self.descripcion = data[:description] if data && data[:description]
  end


private

  # Actualiza la relacion con la editorial
  def actualiza_editorial
    ed_id = @editor.nil? ? nil : Editorial.find_or_create_by_nombre(@editor.strip).id
    self.update_column(:editorial_id, ed_id) unless ed_id == self.editorial_id
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
      logger.info "-----------------> Error obteniendo informacion del libro"
    end
    return return_data
  end

  def get_data_from_todostuslibros
    return_data = nil
    search = self.codigo

    begin
      data = Net::HTTP.get('www.todostuslibros.com', '/busquedas/?keyword=' + search)
      enlace = Hpricot(data).search("//div[@class='details']//h2//a").first if data
      if enlace
        doc = Net::HTTP.get('www.todostuslibros.com', enlace[:href] )
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
      logger.info "-----------------> Error obteniendo informacion del libro"
    end
    return return_data
  end


end
