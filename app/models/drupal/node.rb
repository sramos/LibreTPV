# encoding: UTF-8
#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2015 Santiago Ramos <sramos@sitiodistinto.net> 
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


class Drupal::Node < Drupal

  scope :materia, -> { where(type: 'materias') }
  scope :producto, -> { where(type: 'product') }
  scope :autor, -> { where(type: 'autor') }
  scope :editorial, -> { where(type: 'editorial') }
  
  has_one :stock, class_name: 'Drupal::UcProductStock', foreign_key: :nid
  has_one :atributos, class_name: 'Drupal::UcProducts', foreign_key: :nid
  has_one :body, class_name: 'Drupal::FieldDataBody', foreign_key: :entity_id

  validate :valores_por_defecto
  validates_presence_of :type, :message => "El tipo no puede estar indefinido."
  validates_presence_of :title, :message => "El nombre no puede estar vacío."

  after_create :ajusta_vid

  # Genera los valores por defecto para algunos de los campos
  def valores_por_defecto
    uid ||= 1 
    status ||= 1
    comment ||= 2
    promote ||= 1
    sticky ||= 0
    tnid ||= 0
    translate ||= 0
    changed = Time.now.to_i
    created ||= changed
  end

  def ajusta_vid
    self.update_column(:vid, self.nid)
  end

end
