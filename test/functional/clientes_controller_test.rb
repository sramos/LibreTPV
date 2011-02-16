require 'test_helper'

class ClientesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:clientes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cliente" do
    assert_difference('Cliente.count') do
      post :create, :cliente => { }
    end

    assert_redirected_to cliente_path(assigns(:cliente))
  end

  test "should show cliente" do
    get :show, :id => clientes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => clientes(:one).to_param
    assert_response :success
  end

  test "should update cliente" do
    put :update, :id => clientes(:one).to_param, :cliente => { }
    assert_redirected_to cliente_path(assigns(:cliente))
  end

  test "should destroy cliente" do
    assert_difference('Cliente.count', -1) do
      delete :destroy, :id => clientes(:one).to_param
    end

    assert_redirected_to clientes_path
  end
end
