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


class Pago < ActiveRecord::Base

  belongs_to :factura
  belongs_to :iva
  belongs_to :forma_pago

  #validates_numericality_of :importe, :greater_than => 0, :message => "La factura debe tener un importe."
  validates_numericality_of :importe, :message => "El pago debe tener un importe."
  validates_presence_of :fecha, :message => "El pago debe tener una fecha."
  
  validate :importe_existente

  before_destroy :verificar_borrado

  private
    def importe_existente
      errors.add("Pago", "El pago no puede ser cero") if self.importe.to_f == 0
    end

    # Permite borrar solo si no hay un arqueo posterior para medios de pago que afecten a la caja
    def verificar_borrado
      cierre_caja = Caja.last :conditions => { :cierre_caja => true } if self.forma_pago.caja
      if cierre_caja && (self.fecha < cierre_caja.fecha_hora)
        errors.add( "pago", "No se puede borrar un pago que afecte a la caja con fecha anterior a un cierre de caja." )
        false
      end
    end

end
