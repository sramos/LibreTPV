class Cliente < ActiveRecord::Base

  validates_presence_of :nombre, :cif

  has_many :albarans
  
end
