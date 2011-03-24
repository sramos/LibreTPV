class Pago < ActiveRecord::Base

  belongs_to :factura
  belongs_to :iva
  belongs_to :forma_pago

end
