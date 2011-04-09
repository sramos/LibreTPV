class Factura < ActiveRecord::Base

  belongs_to :albaran
  has_many :pagos

  before_destroy :verificar_borrado

  private
    def verificar_borrado
      errors.add( "pago", "No se puede borrar la factura: Hay pagos realizados." ) unless self.pagos.empty?
    end

end
