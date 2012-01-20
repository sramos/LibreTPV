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

  # Devuelve un array de las líneas de albaran compradas
  def productos_comprados
    albaranes = self.albarans.all :conditions => { :cerrado => true }, :order => "fecha desc"
    # Obtiene las líneas de cada albaran del proveedor
    lineas = []
    albaranes.each { |albaran| albaran.albaran_lineas.each { |linea| lineas.push(linea) } }
    return lineas
  end
end
