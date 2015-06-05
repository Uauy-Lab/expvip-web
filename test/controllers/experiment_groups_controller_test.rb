require 'test_helper'

class ExperimentGroupsControllerTest < ActionController::TestCase
  setup do
    @experiment_group = experiment_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:experiment_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create experiment_group" do
    assert_difference('ExperimentGroup.count') do
      post :create, experiment_group: { description: @experiment_group.description, name: @experiment_group.name }
    end

    assert_redirected_to experiment_group_path(assigns(:experiment_group))
  end

  test "should show experiment_group" do
    get :show, id: @experiment_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @experiment_group
    assert_response :success
  end

  test "should update experiment_group" do
    patch :update, id: @experiment_group, experiment_group: { description: @experiment_group.description, name: @experiment_group.name }
    assert_redirected_to experiment_group_path(assigns(:experiment_group))
  end

  test "should destroy experiment_group" do
    assert_difference('ExperimentGroup.count', -1) do
      delete :destroy, id: @experiment_group
    end

    assert_redirected_to experiment_groups_path
  end
end
