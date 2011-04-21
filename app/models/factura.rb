class Factura < ActiveRecord::Base

  belongs_to :albaran
  belongs_to :proveedor
  has_many :pagos

  before_destroy :verificar_borrado
  validates_numericality_of :importe, :greater_than => 0, :message => "La factura debe tener un importe."
  validates_presence_of :codigo, :message => "La factura debe tener un código."

  # devuelve la base imponible
  def base_imponible
    if ( valor_iva )
      return self.importe / (1 + (valor_iva.to_f - valor_irpf.to_f)/100 )
    else
      return self.importe
    end
  end

  # incluye la base imponible
  def base_imponible=(valor)
    if ( valor_iva )
      self.importe = valor.to_f * (1 + (valor_iva.to_f - valor_irpf.to_f )/100 )
    else
      self.importe=valor.to_f
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
