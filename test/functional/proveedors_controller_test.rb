require 'test_helper'

class ProveedorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:proveedors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create proveedor" do
    assert_difference('Proveedor.count') do
      post :create, :proveedor => { }
    end

    assert_redirected_to proveedor_path(assigns(:proveedor))
  end

  test "should show proveedor" do
    get :show, :id => proveedors(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => proveedors(:one).to_param
    assert_response :success
  end

  test "should update proveedor" do
    put :update, :id => proveedors(:one).to_param, :proveedor => { }
    assert_redirected_to proveedor_path(assigns(:proveedor))
  end

  test "should destroy proveedor" do
    assert_difference('Proveedor.count', -1) do
      delete :destroy, :id => proveedors(:one).to_param
    end

    assert_redirected_to proveedors_path
  end
end
