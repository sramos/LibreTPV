# encoding: UTF-8
#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2019 Santiago Ramos <sramos@sitiodistinto.net>
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

class Almacen < ActiveRecord::Base
  before_destroy :valida_borrado

  has_many :producto_editorial_x_almacenes, dependent: :destroy
  has_many :productos_editorial, through: :producto_editorial_x_almacenes

  validates_presence_of :nombre, message: "El almacen debe tener un nombre."
  validates_uniqueness_of :nombre, message: "Ya existe un almacen con ese nombre."

  private

  # Evita que borremos un almacen con productos asignados
  def valida_borrado
    libros = []
    producto_editorial_x_almacenes.where("cantidad != 0").each do |pexa|
      libros.push pexa.producto_editorial.producto.nombre
    end
    errors.add :base, "No se puede borrar un almacen con libros: cambie primero la ubicación." unless libros.empty?
    return errors.empty?
  end
end
