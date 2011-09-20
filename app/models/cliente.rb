class Cliente < ActiveRecord::Base

  has_many :albarans

  validates_presence_of :nombre, :cif

  before_destroy :verificar_borrado

  def verificar_borrado
    errors.add("Albaran", "El cliente no se puede borrar. Tiene asociados albaranes") unless self.albarans.empty?
    return false unless errors.empty?
  end
  
end
