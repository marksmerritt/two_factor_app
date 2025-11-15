require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    # Sign in a user first since the controller requires authentication
    user = users(:one)
    sign_in user
    get root_url
    assert_response :success
  end
end
