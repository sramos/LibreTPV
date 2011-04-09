class Factura < ActiveRecord::Base

  belongs_to :albaran
  has_many :pagos

  before_destroy :verificar_borrado

  private
    def verificar_borrado
      errors.add( "pago", "Hay pagos asignados" ) unless self.pagos.empty?
    end

end
