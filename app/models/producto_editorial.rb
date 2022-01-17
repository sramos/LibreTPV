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


class ProductoEditorial < ApplicationRecord
  belongs_to :producto
  has_many :producto_editorial_x_almacenes
  has_many :productos_editorial, through: :producto_editorial_x_almacenes

  validates_presence_of :producto_id, :message => "Producto inexistente."
  before_destroy :valida_borrado

  def cantidad
    producto_editorial_x_almacenes.sum(:cantidad)
  end

  private

  # Evita borrar un producto de la editorial del cual hay aún stock
  def valida_borrado
    cantidad = producto_editorial_x_almacenes.sum(:cantidad)
    errors.add :base, "No se puede borrar un producto del cual hay aún ejemplares."
  end
end
