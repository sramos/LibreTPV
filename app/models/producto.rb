class Producto < ActiveRecord::Base
  validates_presence_of :nombre, :codigo
  validates_numericality_of :precio
#  validates_format_of :url_imagen,
#	:with => %r{\.(gif|jpg|png)$}i,
#	:message => 'debe ser una URL de GIF, JPG ' +
#	'o PNG.(gif|jpg|png)'

  belongs_to :familia
  has_many :albaran_linea

end
