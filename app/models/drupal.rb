#--
#
#################################################################################
# LibreTPV - Gestor TPV para Librerias
# Copyright 2015 Santiago Ramos <sramos@sitiodistinto.net> 
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


class Drupal < ApplicationRecord 
  # Para que no nos exija que exista una tabla en BBDD para esta clase
  self.abstract_class = true

  # Conecta con la definicion del database.yml segun el entorno en el que estamos
  establish_connection "drupal_#{Rails.env}"

  # Desactiva el pluralize
  self.pluralize_table_names = false

  # Desactiva la columna de herencia de clases
  self.inheritance_column = nil 

  # Evitamos errores de "ActiveRecord::DangerousAttributeError: changed is defined by ActiveRecord
  def self.instance_method_already_implemented?(method_name)
    (method_name == 'changed?' || method_name == "changed") ? true : super
  end

  # Definimos el prefijo de tablas a usar
  self.table_name_prefix = Rails.application.config.database_configuration["drupal_#{Rails.env}"]['table_name_prefix']
end
