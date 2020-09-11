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

# Gestiona los terminos de taxonomias. Para "vid=2" recoge las taxonomias de "materia"
# Las relaciones con los productos se hacen a traves del taxonomy_index
class Drupal::TaxonomyTermData < Drupal

  # Eliminamos las materias porque se estan manejando como taxonomias
  scope :materia, -> { where(vid: 2) }

  has_one :taxonomy_term_hierarchy, class_name: 'Drupal::TaxonomyTermHierarchy', foreign_key: :tid, dependent: :destroy

  validates_presence_of :name, :message => "El nombre no puede estar vacío."

  after_initialize :defaults, :if => :new_record?
  after_create  :asigna_formato
  after_save    :ajusta_jerarquia

  def defaults
    self.vid ||= 2
    # Format es una palabra reservada, asi que no podemos hacerlo asi...
    #self.format ||= "plain_text"
    self.description ||= ''
    self.weight ||= 1
  end
  def asigna_formato
    self.update_column(:format, 'plain_text')
  end
  def ajusta_jerarquia
    Drupal::TaxonomyTermHierarchy.find_or_create_by_tid(self.tid)
  end
end
