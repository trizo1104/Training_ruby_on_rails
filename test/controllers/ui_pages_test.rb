require "test_helper"

class UiPagesTest < ActionDispatch::IntegrationTest
  setup do
    post user_session_path, params: {
      user: { email: "fixture@example.com", password: "password" }
    }
  end

  test "root renders assignments index" do
    get root_url
    assert_response :success
  end

  test "assignments index renders" do
    get assignments_url
    assert_response :success
  end

  test "assignment detail renders" do
    get assignment_url(1)
    assert_response :success
  end

  test "profile page renders" do
    get profile_url
    assert_response :success
  end
end
