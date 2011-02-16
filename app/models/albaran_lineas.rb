class AlbaranLineas < ActiveRecord::Base

  belongs_to :albaranes
  has_many :productos

end
