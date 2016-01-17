# encoding: UTF-8
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


class Materia < ActiveRecord::Base

  has_many :producto
  has_one :relacion_web, as: :elemento
  belongs_to :familia

  validate :sanea_nombre
  validates_uniqueness_of :nombre, scope: [:familia_id], message: "Nombre repetido.", case_sensitive: false

  after_save :comprueba_valor_defecto
  before_destroy :verificar_borrado
  after_destroy :eliminar_relacion_web

  # Sincroniza con la BBDD de la web
  def sincroniza_drupal
    # Solo sincroniza si esta definida la conexion con la BBDD
    if Rails.application.config.database_configuration["drupal_#{Rails.env}"]
      # Las materias se tratan como taxonomias
      dn = (relacion_web ? Drupal::TaxonomyTermData.find_by_tid(relacion_web.nid) : nil) || Drupal::TaxonomyTermData.new
      dn.update_attribute(:name, self.nombre)
      # Tenemos que capturar aqui los errores que existan
      RelacionWeb.create(elemento_id: self.id, elemento_type: "Materia", nid: dn.tid) if dn && relacion_web.nil?
    end
  end

  private

    def sanea_nombre
      self.nombre.strip!
    end

    # Comprueba que sea el unico valor por defecto de la familia
    def comprueba_valor_defecto
      if valor_defecto && (familia_id_changed? || valor_defecto_changed?)
        mat = Materia.where(familia_id: self.familia_id, valor_defecto: true).where("id != ?", self.id).first
        mat.first.update_column(:valor_defecto, false) if mat
      end
    end

    def verificar_borrado
      errors.add( :base, "No se puede borrar la materia: Hay productos relacionados con ella." ) unless self.producto.empty?
      return errors.empty?
    end

    def eliminar_relacion_web
      relacion_web.update_attribute(:eliminar, true) if self.relacion_web
    end

end
