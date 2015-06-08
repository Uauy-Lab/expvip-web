require 'test_helper'

class TypeOfValuesControllerTest < ActionController::TestCase
  setup do
    @type_of_value = type_of_values(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:type_of_values)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create type_of_value" do
    assert_difference('TypeOfValue.count') do
      post :create, type_of_value: { description: @type_of_value.description, name: @type_of_value.name }
    end

    assert_redirected_to type_of_value_path(assigns(:type_of_value))
  end

  test "should show type_of_value" do
    get :show, id: @type_of_value
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @type_of_value
    assert_response :success
  end

  test "should update type_of_value" do
    patch :update, id: @type_of_value, type_of_value: { description: @type_of_value.description, name: @type_of_value.name }
    assert_redirected_to type_of_value_path(assigns(:type_of_value))
  end

  test "should destroy type_of_value" do
    assert_difference('TypeOfValue.count', -1) do
      delete :destroy, id: @type_of_value
    end

    assert_redirected_to type_of_values_path
  end
end
