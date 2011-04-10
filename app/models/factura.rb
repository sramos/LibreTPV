class Factura < ActiveRecord::Base

  belongs_to :albaran
  has_many :pagos

  before_destroy :verificar_borrado

  private
    def verificar_borrado
      if !self.pagos.empty?
        errors.add( "factura", "No se puede borrar la factura: Hay pagos realizados." ) unless self.pagos.empty?
        false
      end
    end

end
