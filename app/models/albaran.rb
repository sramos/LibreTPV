class Albaran < ActiveRecord::Base

  has_many :albaran_lineas
  belongs_to :cliente
  belongs_to :proveedor
  has_one :factura

end
