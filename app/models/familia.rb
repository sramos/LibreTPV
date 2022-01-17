#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2022 Santiago Ramos <sramos@sitiodistinto.net> 
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

class Familia < ApplicationRecord 

  belongs_to :iva
  has_many :producto
  has_many :materia
  belongs_to :campo

  before_destroy :verificar_borrado
  validates_uniqueness_of :nombre, :message => "Nombre repetido.", :case_sensitive => false

  # Devuelve el id de la materia por defecto para la familia
  def materia_defecto_id
    materia_defecto = materia.find_by_valor_defecto(true)
    return materia_defecto.id if materia_defecto
  end

  private
    def verificar_borrado
      self.errors.add( "familia", "No se puede borrar la familia: Hay productos relacionados con ella." ) unless self.producto.empty?
      return self.errors.empty?
    end

end
