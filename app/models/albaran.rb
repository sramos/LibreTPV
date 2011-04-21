class Albaran < ActiveRecord::Base

  has_many :albaran_lineas, :dependent => :destroy
  belongs_to :cliente
  belongs_to :proveedor
  has_one :factura

  def 
end
