require 'test_helper'

class WellcomeControllerTest < ActionController::TestCase
  test "should get default" do
    get :default
    assert_response :success
  end

  test "should get search_gene" do
    get :search_gene
    assert_response :success
  end

end
