class AlbaranLinea < ActiveRecord::Base

  has_one :producto
  belongs_to :albaran

end
