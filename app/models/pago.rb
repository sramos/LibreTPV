class Pago < ActiveRecord::Base

  belongs_to :factura
  belongs_to :iva
  belongs_to :forma_pago

  validates_numericality_of :importe, :greater_than => 0, :message => "La factura debe tener un importe."

end
