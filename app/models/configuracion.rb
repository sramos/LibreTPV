class Configuracion < ActiveRecord::Base

  def self.valor parametro
    elemento = Configuracion.find_by_nombre_param(parametro)
    return elemento.valor_param if elemento
  end

  def self.numero_nueva_venta
    elemento = Configuracion.find_by_nombre_param("FACTURAS VENTA")
    valor = elemento.valor_param.to_i + 1
    elemento.valor_param = valor 
    elemento.save
    return elemento.errors.empty? ? valor : "ERROR"
  end

end
