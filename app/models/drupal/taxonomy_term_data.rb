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

# Gestiona los terminos de taxonomias. Para "vid=2" recoge las taxonomias de "materia"
class Drupal::TaxonomyTermData < Drupal

  # Eliminamos las materias porque se estan manejando como taxonomias
  scope :materia, -> { where(vid: 2) }

  validates_presence_of :name, :message => "El nombre no puede estar vacío."

  after_initialize :defaults, :if => :new_record?
  after_create  :asigna_formato

  def defaults
    self.vid ||= 2
    # Format es una palabra reservada, asi que no podemos hacerlo asi...
    #self.format ||= "plain_text"
    self.description ||= ''
    self.weight ||= 0
  end
  def asigna_formato
    self.update_column(:format, 'plain_text')
  end
end
