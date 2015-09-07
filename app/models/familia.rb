class Familia < ActiveRecord::Base

  belongs_to :iva
  has_many :producto
  has_many :materia
  belongs_to :campo

  before_destroy :verificar_borrado
  validates_uniqueness_of :nombre, :message => "Nombre repetido.", :case_sensitive => false

  # Devuelve el id de la materia por defecto para la familia
  def materia_defecto_id
    materia_defecto = materia.find_by_valor_defecto(true)
    return materia_defecto.id if materia_defecto
  end

  private
    def verificar_borrado
      productos=Producto.find :all, :conditions => { :familia_id => self.id }
      if !productos.empty?
        errors.add( "familia", "No se puede borrar la familia: Hay productos relacionados con ella." ) 
        false
      end
    end

end
