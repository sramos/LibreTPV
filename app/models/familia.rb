class Familia < ActiveRecord::Base

  belongs_to :iva
  has_many :producto
  belongs_to :campo

  before_destroy :verificar_borrado

  private
    def verificar_borrado
      productos=Producto.find :all, :conditions => { :familia_id => self.id }
      if !productos.empty?
        errors.add( "familia", "No se puede borrar la familia: Hay productos relacionados con ella." ) 
        false
      end
    end

end
