require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @password = "password"
    @user_attributes = {
      email: "auth-#{SecureRandom.hex(4)}@example.com",
      username: "auth_#{SecureRandom.hex(4)}",
      first_name: "Alex",
      last_name: "Johnson",
      department: "Engineering",
      password: @password,
      password_confirmation: @password
    }
  end

  test "valid registration signs the user in and redirects to assignments" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: { user: @user_attributes }
    end

    assert_redirected_to assignments_path
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Alex Johnson"
  end

  %i[username first_name last_name department].each do |field|
    test "registration requires #{field}" do
      @user_attributes.delete(field)

      assert_no_difference "User.count" do
        post user_registration_path, params: { user: @user_attributes }
      end

      assert_response :unprocessable_entity
      assert_includes response.body, field.to_s.humanize
    end
  end

  test "registration rejects an invalid email" do
    @user_attributes[:email] = "not-an-email"

    post user_registration_path, params: { user: @user_attributes }

    assert_response :unprocessable_entity
    assert_includes response.body, "Email"
  end

  test "registration rejects an invalid password" do
    @user_attributes[:password] = "short"
    @user_attributes[:password_confirmation] = "short"

    post user_registration_path, params: { user: @user_attributes }

    assert_response :unprocessable_entity
    assert_includes response.body, "Password"
  end

  test "registration rejects a duplicate username case insensitively" do
    User.create!(@user_attributes)
    @user_attributes.merge!(
      email: "other-#{SecureRandom.hex(4)}@example.com",
      username: @user_attributes[:username].upcase
    )

    assert_no_difference "User.count" do
      post user_registration_path, params: { user: @user_attributes }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Username has already been taken"
  end

  test "valid sign in redirects to assignments" do
    user = User.create!(@user_attributes)

    post user_session_path, params: { user: { email: user.email, password: @password } }

    assert_redirected_to assignments_path
  end

  test "invalid sign in renders a visible error" do
    user = User.create!(@user_attributes)

    post user_session_path, params: { user: { email: user.email, password: "incorrect" } }

    assert_response :unprocessable_entity
    assert_includes response.body, "Invalid email or password"
  end

  test "sign out redirects to the sign-in page" do
    user = User.create!(@user_attributes)
    post user_session_path, params: { user: { email: user.email, password: @password } }

    delete destroy_user_session_path

    assert_redirected_to new_user_session_path
  end

  test "unauthenticated users are redirected from assignments and profile" do
    get assignments_path
    assert_redirected_to new_user_session_path

    get profile_path
    assert_redirected_to new_user_session_path
  end

  test "authentication pages use the authentication layout" do
    get new_user_session_path
    assert_response :success
    assert_not_includes response.body, "Personal assignment workspace"
    assert_not_includes response.body, "My Assignments"

    get new_user_registration_path
    assert_response :success
    assert_not_includes response.body, "Personal assignment workspace"
    assert_not_includes response.body, "My Assignments"
  end

  test "language selection persists through Devise pages and validation errors" do
    patch locale_path, params: { locale: :vi }
    assert_redirected_to root_path

    get new_user_session_path
    assert_response :success
    assert_includes response.body, "Đăng nhập"

    post user_session_path, params: { user: { email: "missing@example.com", password: "incorrect" } }
    assert_response :unprocessable_entity
    assert_includes response.body, "không hợp lệ"
  end
end
