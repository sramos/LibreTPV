class FormaPago < ActiveRecord::Base

  has_many :pago

  before_destroy :verificar_borrado

  private
    def verificar_borrado
      pagos=Pago.find :all, :conditions => { :forma_pago_id => self.id }
      if !pagos.empty?
        errors.add( "forma_pago", "No se puede borrar la forma de pago: Hay pagos realizados con ella." )
        false
      end
    end

end
