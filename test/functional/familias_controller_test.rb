require 'test_helper'

class FamiliasControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:familias)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create familia" do
    assert_difference('Familia.count') do
      post :create, :familia => { }
    end

    assert_redirected_to familia_path(assigns(:familia))
  end

  test "should show familia" do
    get :show, :id => familias(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => familias(:one).to_param
    assert_response :success
  end

  test "should update familia" do
    put :update, :id => familias(:one).to_param, :familia => { }
    assert_redirected_to familia_path(assigns(:familia))
  end

  test "should destroy familia" do
    assert_difference('Familia.count', -1) do
      delete :destroy, :id => familias(:one).to_param
    end

    assert_redirected_to familias_path
  end
end
