class Proveedor < ActiveRecord::Base

  validates_presence_of :nombre, :nif

  has_many :albarans

end
