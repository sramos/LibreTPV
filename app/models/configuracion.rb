#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2011-2022 Santiago Ramos <sramos@sitiodistinto.net> 
#
#    Este programa es software libre: usted puede redistribuirlo y/o modificarlo 
#    bajo los términos de la Licencia Pública General GNU publicada 
#    por la Fundación para el Software Libre, ya sea la versión 3 
#    de la Licencia, o (a su elección) cualquier versión posterior.
#
#    Este programa se distribuye con la esperanza de que sea útil, pero 
#    SIN GARANTÍA ALGUNA; ni siquiera la garantía implícita 
#    MERCANTIL o de APTITUD PARA UN PROPÓSITO DETERMINADO. 
#    Consulte los detalles de la Licencia Pública General GNU para obtener 
#    una información más detallada. 
#
#    Debería haber recibido una copia de la Licencia Pública General GNU 
#    junto a este programa. 
#    En caso contrario, consulte <http://www.gnu.org/licenses/>.
#################################################################################
#
#++


class Configuracion < ApplicationRecord

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
