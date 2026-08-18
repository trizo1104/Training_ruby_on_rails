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

  test "unknown routes render the not found page" do
    get "/page-that-does-not-exist"

    assert_response :not_found
    assert_select "p", text: "404"
    assert_select "h1", text: "Page not found"
  end

  test "not found page does not require authentication" do
    delete destroy_user_session_path
    get "/page-that-does-not-exist"

    assert_response :not_found
    assert_select "h1", text: "Page not found"
  end

  test "missing assignments render the not found page" do
    get assignment_url(999_999)

    assert_response :not_found
    assert_select "h1", text: "Page not found"
  end

  test "language selection renders Vietnamese application text" do
    patch locale_path, params: { locale: :vi }
    get assignments_path

    assert_response :success
    assert_includes response.body, "Bài tập của tôi"
    assert_includes response.body, "Đăng xuất"
  end
end
