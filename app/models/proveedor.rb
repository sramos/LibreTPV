#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2013 Santiago Ramos <sramos@sitiodistinto.net> 
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


class Proveedor < ActiveRecord::Base

  has_many :albarans
  has_many :facturas

  validates_presence_of :nombre, :cif

  before_destroy :verificar_borrado

  def verificar_borrado
    errors.add("Albaran", "El proveedor no se puede borrar. Tiene asociados albaranes") unless self.albarans.empty?
    errors.add("Factura", "El proveedor no se puede borrar. Tiene asociadas facturas") unless self.facturas.empty?
    return false unless errors.empty?
  end

  # Devuelve un array de las líneas de albaran compradas
  def productos_comprados
    albaranes = self.albarans.all :conditions => { :cerrado => true }, :order => "fecha desc"
    # Obtiene las líneas de cada albaran del proveedor
    lineas = []
    albaranes.each { |albaran| albaran.albaran_lineas.each { |linea| lineas.push(linea) } }
    return lineas
  end
end
