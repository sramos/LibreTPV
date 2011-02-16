class Familia < ActiveRecord::Base

  has_one :iva
  belongs_to :producto

end
