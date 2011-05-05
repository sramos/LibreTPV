class Configuracion < ActiveRecord::Base

  def self.valor parametro
    elemento = Configuracion.find_by_nombre_param(parametro)
    return elemento.valor_param if elemento
  end

end
