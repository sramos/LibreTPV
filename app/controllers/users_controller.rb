class UsersController < ApplicationController
  before_filter :verificar_administrador,
	               only: [:index, :listado, :editar, :modificar, :borrar]

  def index
    redirect_to action: :listado
  end

  def listado
    flash[:mensaje] = "Listado de usuarios"
    @users = User.order :name
    @formato_xls = @users.count
    respond_to do |format|
      format.html
      format.xls do
        @tipo = "users"
        @objetos = @users
        render 'comunes_xls/listado', :layout => false
      end
    end
  end

  def editar
    @user = User.find_by_id(params[:id]) || User.new
    render partial: "formulario"
  end

  def modificar
    @user = User.find_by_id(params[:id]) || User.new
    @user.update_attributes params[:user]
    flash[:error] = @user
    redirect_to action: :listado
  end

  def borrar
    @user = User.find_by_id(params[:id])
    @user.destroy
    flash[:error] = @user
    redirect_to action: :listado
  end

  private

  def verificar_administrador
    unless current_user.acceso_admin
      flash[:error] = "No tiene perimisos suficientes para realizar esta acción"
      redirect_to root_path
    end
  end

end
