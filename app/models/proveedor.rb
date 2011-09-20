class Proveedor < ActiveRecord::Base

  has_many :albarans
  has_many :facturas

  validates_presence_of :nombre, :cif

  before_destroy :verificar_borrado

  def verificar_borrado
    errors.add("Albaran", "El proveedor no se puede borrar. Tiene asociados albaranes") unless self.albarans.empty?
    errors.add("Factura", "El proveedor no se puede borrar. Tiene asociadas facturas") unless self.facturas.empty?
    return false unless errors.empty?
  end

end
