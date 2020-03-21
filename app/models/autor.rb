#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2015 Santiago Ramos <sramos@sitiodistinto.net> 
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


class Autor < ActiveRecord::Base

  has_many :autor_x_producto
  has_many :producto, through: :autor_x_producto

  has_one :relacion_web, as: :elemento

  validate :valida_nombre
  validates_uniqueness_of :nombre, :message => "Nombre repetido.", :case_sensitive => false

  before_destroy :verificar_borrado
  after_destroy :eliminar_relacion_web

  # Renombra a un autor (si ya existe alguno con el nombre propuesto, mueve los libros al nuevo)
  def renombra nuevo_nombre=nil, reasigna_productos=false
    nuevo_nombre = sanea_nombre(nuevo_nombre)
    if nuevo_nombre && self.nombre != nuevo_nombre
      # Busca si existe ya algun autor con ese nombre
      existente = Autor.find_by_nombre nuevo_nombre
      # Si ya existe el autor, 
      if existente && reasigna_productos
        autor_x_producto.update_all(autor_id: existente.id)
        self.destroy
      else
        self.update_attributes(nombre: nuevo_nombre) 
      end
    end 
  end

  private
    def valida_nombre
      self.nombre = sanea_nombre(self.nombre)
      self.errors.add :base, "Nombre no puede estar vacío" if self.nombre.blank?
      return self.errors.empty?
    end

    def sanea_nombre nom
      nom = nil if nom.upcase == "&NBSP;"
      nom = nom.strip.mb_chars.upcase if nom
      return nom
    end

    def verificar_borrado
      errors.add( :base, "No se puede borrar el autor: Hay productos asociados a él." ) unless self.autor_x_producto.empty?
      return self.errors.empty?
    end

    def eliminar_relacion_web
      relacion_web.update_attribute(:eliminar, true) if self.relacion_web
    end

end
