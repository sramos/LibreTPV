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

# Gestiona las relaciones entre nodos
class Drupal::FieldDataEndpoints < Drupal

  after_initialize :defaults, :if => :new_record?
  belongs_to :node, class_name: 'Drupal::Node', foreign_key: :endpoints_entity_id

  scope :autor, -> { where(bundle: 'esta_escrito_por') }
  scope :materia, -> { where(bundle: 'pertenece_a') }


  def relacionado
    table_name = Drupal::FieldDataEndpoints.table_name
    Drupal::Node.joins(:relation).where(table_name + ".entity_id = ? AND " + table_name + ".endpoints_r_index != ?", self.entity_id, self.endpoints_r_index).first
  end

  def defaults
    self.entity_type = "relation"
    self.language = "und"
    self.endpoints_entity_type = "node"
    #self.bundle = "esta_escrito_por" -> Para autores de un libro
    #self.bundle = "pertenece_a"      -> Para la materia de un libro
    #self.endpoints_r_index = 0       -> Para un extremo
    #self.endpoints_r_index = 1       -> Para otro extremo
  end
end
