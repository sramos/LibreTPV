class Factura < ActiveRecord::Base

  belongs_to :albaran
  has_many :pagos

end
