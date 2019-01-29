class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :lockable,
	 :timeoutable, :trackable

  validate :password_complexity
  
  def password_complexity
    if password.present? and password.size < 6 and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./)
      errors.add :password, "debe ser mayor de 6 caracteres, incluyendo al menos: una letra mayuscula, una minuscula, y un número"
    end
  end
end
