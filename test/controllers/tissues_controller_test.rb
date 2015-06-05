require 'test_helper'

class TissuesControllerTest < ActionController::TestCase
  setup do
    @tissue = tissues(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tissues)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tissue" do
    assert_difference('Tissue.count') do
      post :create, tissue: { description: @tissue.description, name: @tissue.name }
    end

    assert_redirected_to tissue_path(assigns(:tissue))
  end

  test "should show tissue" do
    get :show, id: @tissue
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tissue
    assert_response :success
  end

  test "should update tissue" do
    patch :update, id: @tissue, tissue: { description: @tissue.description, name: @tissue.name }
    assert_redirected_to tissue_path(assigns(:tissue))
  end

  test "should destroy tissue" do
    assert_difference('Tissue.count', -1) do
      delete :destroy, id: @tissue
    end

    assert_redirected_to tissues_path
  end
end
