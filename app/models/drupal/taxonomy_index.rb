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

# Gestiona las vinculaciones entre nodos y taxonomias
class Drupal::TaxonomyIndex < Drupal

  #scope :materia, -> { where(vid: 2) }
  self.primary_key = :nid 

  belongs_to :product, class_name: 'Drupal::Node', foreign_key: :nid
  belongs_to :materia, class_name: 'Drupal::TaxonomyTermData', foreign_key: :tid

  validates_presence_of :nid, :message => "El libro no puede estar vacío."
  validates_presence_of :tid, :message => "La materia no puede estar vacía."

  #after_save   :valores_modificacion
  after_create :valores_por_defecto

  # Guarda la fecha de modificacion (no existe fecha de modificacion en esa tabla)
  #def valores_modificacion
  #  values = { uid: 1,
  #             changed: Time.now.to_i,
  #           }
  #  # Necesitamos hacer esto porque hasta Rails4 no hay self.update_columns
  #  values.each{|k,v| self.update_column(k,v)}
  #end

  def valores_por_defecto 
    values = { created: Time.now.to_i,
             }
    # Necesitamos hacer esto porque hasta Rails4 no hay self.update_columns
    values.each{|k,v| self.update_column(k,v)}
  end

end
