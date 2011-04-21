class Albaran < ActiveRecord::Base

  has_many :albaran_lineas, :dependent => :destroy
  belongs_to :cliente
  belongs_to :proveedor
  has_one :factura

  before_destroy :verificar_borrado

  # Devuelve la base imponible de los productos
  def base_imponible
    subtotal = 0
    lineas = self.albaran_lineas
    lineas.each do |linea|
      subtotal += linea.subtotal
    end
    return subtotal
  end

  # Devuelve la suma del iva aplicado en los productos
  def iva_aplicado
    iva_total = 0
    lineas = self.albaran_lineas
    lineas.each do |linea|
      iva_total += (linea.total-linea.subtotal)
    end
    return iva_total
  end

  private
    def verificar_borrado
      if !self.factura.empty?
        errors.add( "albaran", "No se puede borrar albaran: Hay facturas asociadas." ) unless self.pagos.empty?
        false
      end
    end

end
