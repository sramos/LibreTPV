class Iva < ActiveRecord::Base

  has_many :familia

  before_destroy :verificar_borrado

  private
    def verificar_borrado
      familias=Familia.find :all, :conditions => { :iva_id => self.id }
      if !familias.empty?
        errors.add( "iva", "No se puede borrar el tipo de iva: Hay familias que lo usan." )
        false
      end
    end

end
