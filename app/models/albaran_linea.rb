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


class AlbaranLinea < ActiveRecord::Base

  belongs_to :producto
  belongs_to :albaran
 
  #belongs_to :linea_descontada, :foreign_key => :linea_descuento_id, :class_name => "AlbaranLinea"
  has_one :linea_descuento, :foreign_key => :linea_descuento_id, :class_name => "AlbaranLinea", :dependent => :destroy

  validate :comprueba_linea
  after_create :valida_creacion
  before_destroy :valida_borrado


  # devuelve el subtotal (sin iva)
  def subtotal
    if ( self.albaran.proveedor_id )
      precio = self.precio_compra
    else
      precio = self.precio_venta / (1 + self.iva.to_f/100)
      #precio = self.producto.precio / (1 + self.producto.familia.iva.valor.to_f/100)
    end
    return precio * self.cantidad * (1 - self.descuento.to_f/100)
  end

  # devuelve el total (con iva)
  def total
    if ( self.albaran.proveedor_id )
      precio = self.precio_compra * (1 + self.iva.to_f/100)
    else
      precio = self.precio_venta
      #precio = self.producto.precio
    end
    return precio * self.cantidad * (1 - self.descuento.to_f/100)
  end

  # genera una linea de descuento en base a la presente
  def nueva_linea_descuento
    if self.albaran.cliente && self.producto && self.linea_descuento.nil?
      credito = self.albaran.cliente.credito_acumulado
      descontar = self.total > credito ? credito : self.total
      AlbaranLinea.create(:albaran_id => self.albaran_id, :cantidad => 1,
        :nombre_producto => "Descuento " + self.nombre_producto,
        :iva => self.producto.familia.iva.valor, :precio_venta => 0-descontar,
	:linea_descuento_id => self.id )
    end
  end

  private
    def comprueba_linea
      # Comprueba que exista producto asociado, o sea entrada por concepto
      if self.producto.nil? 
        errors.add( "albaran_linea", "No se introdujo el concepto" ) unless self.nombre_producto
        errors.add( "albaran_linea", "No se introdujo el tipo de IVA aplicado" ) unless self.iva
        errors.add( "albaran_linea", "No se introdujo el precio" ) unless self.precio_compra || self.precio_venta
      end
      return false unless errors.empty?
    end

    # Tras la creacion, toquetea cosas en la linea 
    def valida_creacion
      # Mete automaticamente los campos que se necesiten si la linea esta vinculada a un producto
      if self.producto
        self.precio_venta = self.producto.precio if !self.albaran.cliente.nil?
        self.iva = self.producto.familia.iva.valor
        self.nombre_producto = self.producto.nombre 
      # Si la linea no esta vinculada a un producto, toquetea el nombre si no lo tiene
      else
        self.nombre_producto = "N/A" unless self.nombre_producto && self.nombre_producto != ""
      end
      self.save
      # Si es una linea de descuento, reduce el credito
      if self.linea_descuento_id
        self.albaran.cliente.credito_acumulado += self.precio_venta
        self.albaran.cliente.save
      end
    end

    # Antes del borrado, toquetea cosas
    def valida_borrado
      # Si es una linea de descuento, aumenta el credito del cliente
      if self.linea_descuento_id
        self.albaran.cliente.credito_acumulado -= self.precio_venta
        self.albaran.cliente.save
      end
    end
end
