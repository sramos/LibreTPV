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
