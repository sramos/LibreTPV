class Configuracion < ActiveRecord::Base

  def self.valor parametro
    return Configuracion.find_by_nombre_param(parametro).valor_param
  end

end
