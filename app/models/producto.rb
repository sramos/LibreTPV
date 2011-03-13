class Producto < ActiveRecord::Base
  validates_presence_of :nombre, :codigo
  #validates_numericality_of :precio, :cantidad
#  validates_format_of :url_imagen,
#	:with => %r{\.(gif|jpg|png)$}i,
#	:message => 'debe ser una URL de GIF, JPG ' +
#	'o PNG.(gif|jpg|png)'
  validates_numericality_of :precio, :greater_than => 0, :message => "El producto tiene que tener un precio de venta."

  belongs_to :familia
  has_many :albaran_linea

end
