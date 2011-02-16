require 'test_helper'

class IvasControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ivas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create iva" do
    assert_difference('Iva.count') do
      post :create, :iva => { }
    end

    assert_redirected_to iva_path(assigns(:iva))
  end

  test "should show iva" do
    get :show, :id => ivas(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => ivas(:one).to_param
    assert_response :success
  end

  test "should update iva" do
    put :update, :id => ivas(:one).to_param, :iva => { }
    assert_redirected_to iva_path(assigns(:iva))
  end

  test "should destroy iva" do
    assert_difference('Iva.count', -1) do
      delete :destroy, :id => ivas(:one).to_param
    end

    assert_redirected_to ivas_path
  end
end
