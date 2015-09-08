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
#
# hay que actualizar tambien?
#  * dr_node_comment_statistics

class Drupal::Node < Drupal

  # Eliminamos las materias porque se estan manejando como taxonomias
  #scope :materia, -> { where(type: 'materias') }
  scope :producto, -> { where(type: 'product') }
  scope :autor, -> { where(type: 'autor') }
  scope :editorial, -> { where(type: 'editorial') }
  
  has_one :stock, class_name: 'Drupal::UcProductStock', foreign_key: :nid
  has_one :atributos, class_name: 'Drupal::UcProducts', foreign_key: :nid
  has_one :body, class_name: 'Drupal::FieldDataBody', foreign_key: :entity_id
  has_one :materia, class_name: 'Drupal::TaxonomyIndex', foreign_key: :nid
  has_many :relation, class_name: 'Drupal::FieldDataEndpoints', foreign_key: :endpoints_entity_id
  has_many :node_revision, class_name: 'Drupal::NodeRevision', foreign_key: :nid, dependent: :destroy

  validates_presence_of :type, :message => "El tipo no puede estar indefinido."
  validates_presence_of :title, :message => "El nombre no puede estar vacío."

  after_initialize :defaults, :if => :new_record?
  before_save  :valores_modificado
  after_save :ajusta_vid
  after_destroy :elimina_vid

  # Guarda la fecha de modificacion 
  def valores_modificado
    self.uid = 1
    self.changed = Time.now.to_i
  end

  # Asigna los valores por defecto
  def defaults 
    self.status = 1
    self.comment = 2
    self.promote = 1
    self.sticky = 0
    self.tnid = 0
    self.language = "es"
    self.translate = 0
    self.created = Time.now.to_i
  end

  # Asigna la revision del nodo 
  def ajusta_vid 
    #  * dr_node_revision
    #     (112,112,117,'Grijalbo','',1369206981,1,2,1,0) -> (nid, vid, uid, title, log, timestamp, status, comment, promote, sticky)
    revision = Drupal::NodeRevision.find_or_create_by_nid(self.nid)
    if revision
      revision.update_column(:title, self.title)
      self.update_column(:vid, revision.vid)
    end
  end

  # Relaciones entre nodos
  #
  # Autores de un libro...
  #SELECT node2.nid AS autores_nid FROM dr_node node1
  #  LEFT JOIN dr_field_data_endpoints fde1 ON node1.nid = fde1.endpoints_entity_id AND fde1.bundle = 'esta_escrito_por' AND fde1.endpoints_entity_type = 'node'
  #  LEFT JOIN dr_field_data_endpoints fde2 ON fde1.entity_id = fde2.entity_id AND fde2.endpoints_entity_type = 'node' AND fde1.endpoints_r_index != fde2.endpoints_r_index
  #  LEFT JOIN dr_node node2 ON fde2.endpoints_entity_id = node2.nid AND fde2.endpoints_entity_type = 'node'
  #  WHERE node1.nid = '54' AND node1.status = '1' AND node1.type = 'product';

  # Editorial de un libro (igual, pero cambiando la relacion a 'pertenece_a'
  #SELECT node2.nid AS materias_nid FROM dr_node node1
  #  LEFT JOIN dr_field_data_endpoints fde1 ON node1.nid = fde1.endpoints_entity_id AND fde1.bundle = 'pertenece_a' AND fde1.endpoints_entity_type = 'node'
  #  LEFT JOIN dr_field_data_endpoints fde2 ON fde1.entity_id = fde2.entity_id AND fde2.endpoints_entity_type = 'node' AND fde1.endpoints_r_index != fde2.endpoints_r_index
  #  LEFT JOIN dr_node node2 ON fde2.endpoints_entity_id = node2.nid AND fde2.endpoints_entity_type = 'node'
  #  WHERE node1.nid = '54' AND node1.status = '1' AND node1.type = 'product';

end
