class Familia < ActiveRecord::Base

  belongs_to :iva
  has_many :producto
  belongs_to :campo

end
