class Albaranes < ActiveRecord::Base

  belongs_to :proveedores
  belongs_to :clientes

end
