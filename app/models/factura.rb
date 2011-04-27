class Factura < ActiveRecord::Base

  belongs_to :albaran
  belongs_to :proveedor
  has_many :pagos

  before_destroy :verificar_borrado
  validates_numericality_of :importe, :greater_than => 0, :message => "La factura debe tener un importe."
  validates_presence_of :codigo, :message => "La factura debe tener un código."

  # devuelve el debe de una factura
  def debe
    if (self.albaran && ( (self.albaran.proveedor_id && self.importe >= 0) || (self.albaran.cliente_id && self.importe < 0))) || (self.proveedor && self.importe >= 0)
      return self.importe.abs
    else
      return nil 
    end
  end

  # devuelve el haber de una factura
  def haber
    if (self.albaran && ( (self.albaran.cliente_id && self.importe >= 0) || (self.albaran.proveedor_id && self.importe <0))) || (self.proveedor && self.importe < 0)
      return self.importe.abs
    else
      return nil 
    end
  end

  # devuelve el concepto de una factura
  def concepto
    if (self.albaran)
      if self.albaran.cliente_id
        concepto = (self.importe>=0?"Venta ":"Devolucion ") + self.albaran.cliente.nombre
      else
        concepto = (self.importe>=0?"Compra ":"Devolucion compra ") + self.albaran.proveedor.nombre
      end
    else
      concepto = (self.importe>0?"Factura ":"Cobro ") + (self.proveedor ? self.proveedor.nombre : "REVISAME!!!")
      #concepto = (importe>0?"Factura ":"Cobro ") + "REVISAME"
    end
    return concepto
  end

  # devuelve la base imponible tenga o no un albaran asociado
  def base_imponible
    # Si hay un iva asociado a la factura completa (aunque sea 0)
    if ( self.valor_iva )
      return self.importe / (1 + (valor_iva.to_f - valor_irpf.to_f)/100 )
    # Si la factura corresponde a un albaran 
    elsif self.albaran
      return self.albaran.base_imponible 
    end
  end

  # incluye la base imponible (solo en el caso de que no haya albaran asociado)
  def base_imponible=(valor)
    if ( self.valor_iva )
      self.importe = valor.to_f * (1 + (valor_iva.to_f - valor_irpf.to_f )/100 )
    else
      self.importe=valor.to_f
    end
  end

  # devuelve el irpf
  def irpf
    return self.base_imponible.abs * self.valor_irpf.to_f/100
  end

  # devuelve el iva aplicado
  def iva_aplicado
    if ( self.valor_iva )
      return self.base_imponible.abs * self.valor_iva.to_f/100
    else
      return self.importe - self.base_imponible
    end
  end

  private
    def verificar_borrado
      if !self.pagos.empty?
        errors.add( "factura", "No se puede borrar la factura: Hay pagos realizados." ) unless self.pagos.empty?
        false
      end
    end

end
