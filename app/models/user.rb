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

class User < ApplicationRecord 
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :lockable,
	       :timeoutable, :trackable

  validate :password_complexity
  validates :name, presence: true
  before_update :prevent_disable_all_admins
  before_destroy :prevent_destroy_all_admins

  def user_sections
    permisos = []
    User.column_names.select{|n| n.match(/^acceso_/)}.each do |permiso|
      permisos.push(permiso.match(/^acceso_(.*)/)[1]) if self.send(permiso)
    end
    return permisos.join(", ")
  end

  def password_complexity
    if password.present? and password.size < 6 and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./)
      errors.add :password, "debe ser mayor de 6 caracteres, incluyendo al menos: una letra mayuscula, una minuscula, y un número"
    end
  end

  def prevent_disable_all_admins
    if acceso_admin_was && !acceso_admin && User.where(acceso_admin: true).count == 1
      self.errors[:base] << "No se puede deshabilitar a todos los administradores"
      return false
    end
  end

  def prevent_destroy_all_admins
    # Si somos los unicos administradores, evitamos el borrado
    if acceso_admin && User.where(acceso_admin: true).count == 1
      self.errors[:base] << "No se pueden borrar todos los administradores"
      return false
    end
  end
end
