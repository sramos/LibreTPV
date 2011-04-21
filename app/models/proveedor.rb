class Proveedor < ActiveRecord::Base

  validates_presence_of :nombre, :cif

  has_many :albarans
  has_many :facturas

end
