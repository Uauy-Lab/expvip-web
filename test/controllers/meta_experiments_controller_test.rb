require 'test_helper'

class MetaExperimentsControllerTest < ActionController::TestCase
  setup do
    @meta_experiment = meta_experiments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:meta_experiments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create meta_experiment" do
    assert_difference('MetaExperiment.count') do
      post :create, meta_experiment: { description: @meta_experiment.description, gene_set_id: @meta_experiment.gene_set_id, name: @meta_experiment.name }
    end

    assert_redirected_to meta_experiment_path(assigns(:meta_experiment))
  end

  test "should show meta_experiment" do
    get :show, id: @meta_experiment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @meta_experiment
    assert_response :success
  end

  test "should update meta_experiment" do
    patch :update, id: @meta_experiment, meta_experiment: { description: @meta_experiment.description, gene_set_id: @meta_experiment.gene_set_id, name: @meta_experiment.name }
    assert_redirected_to meta_experiment_path(assigns(:meta_experiment))
  end

  test "should destroy meta_experiment" do
    assert_difference('MetaExperiment.count', -1) do
      delete :destroy, id: @meta_experiment
    end

    assert_redirected_to meta_experiments_path
  end
end
