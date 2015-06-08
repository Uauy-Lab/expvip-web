require 'test_helper'

class ExpressionValuesControllerTest < ActionController::TestCase
  setup do
    @expression_value = expression_values(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expression_values)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expression_value" do
    assert_difference('ExpressionValue.count') do
      post :create, expression_value: { experiment_id: @expression_value.experiment_id, gene_id: @expression_value.gene_id, meta_experiment_id: @expression_value.meta_experiment_id, type_of_value_id: @expression_value.type_of_value_id, value: @expression_value.value }
    end

    assert_redirected_to expression_value_path(assigns(:expression_value))
  end

  test "should show expression_value" do
    get :show, id: @expression_value
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @expression_value
    assert_response :success
  end

  test "should update expression_value" do
    patch :update, id: @expression_value, expression_value: { experiment_id: @expression_value.experiment_id, gene_id: @expression_value.gene_id, meta_experiment_id: @expression_value.meta_experiment_id, type_of_value_id: @expression_value.type_of_value_id, value: @expression_value.value }
    assert_redirected_to expression_value_path(assigns(:expression_value))
  end

  test "should destroy expression_value" do
    assert_difference('ExpressionValue.count', -1) do
      delete :destroy, id: @expression_value
    end

    assert_redirected_to expression_values_path
  end
end
