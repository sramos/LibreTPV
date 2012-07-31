class Materia < ActiveRecord::Base

  has_many :producto

  before_destroy :verificar_borrado

  private
    def verificar_borrado
      productos=Producto.find :all, :conditions => { :materia_id => self.id }
      if !productos.empty?
        errors.add( "familia", "No se puede borrar la materia: Hay productos relacionados con ella." ) 
        false
      end
    end

end
