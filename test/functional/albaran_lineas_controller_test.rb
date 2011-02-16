require 'test_helper'

class AlbaranLineasControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:albaran_lineas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create albaran_linea" do
    assert_difference('AlbaranLinea.count') do
      post :create, :albaran_linea => { }
    end

    assert_redirected_to albaran_linea_path(assigns(:albaran_linea))
  end

  test "should show albaran_linea" do
    get :show, :id => albaran_lineas(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => albaran_lineas(:one).to_param
    assert_response :success
  end

  test "should update albaran_linea" do
    put :update, :id => albaran_lineas(:one).to_param, :albaran_linea => { }
    assert_redirected_to albaran_linea_path(assigns(:albaran_linea))
  end

  test "should destroy albaran_linea" do
    assert_difference('AlbaranLinea.count', -1) do
      delete :destroy, :id => albaran_lineas(:one).to_param
    end

    assert_redirected_to albaran_lineas_path
  end
end
