require 'test_helper'

class GeneSetsControllerTest < ActionController::TestCase
  setup do
    @gene_set = gene_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gene_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gene_set" do
    assert_difference('GeneSet.count') do
      post :create, gene_set: { description: @gene_set.description, name: @gene_set.name }
    end

    assert_redirected_to gene_set_path(assigns(:gene_set))
  end

  test "should show gene_set" do
    get :show, id: @gene_set
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gene_set
    assert_response :success
  end

  test "should update gene_set" do
    patch :update, id: @gene_set, gene_set: { description: @gene_set.description, name: @gene_set.name }
    assert_redirected_to gene_set_path(assigns(:gene_set))
  end

  test "should destroy gene_set" do
    assert_difference('GeneSet.count', -1) do
      delete :destroy, id: @gene_set
    end

    assert_redirected_to gene_sets_path
  end
end
