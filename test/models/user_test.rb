require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "full_name joins first and last names" do
    user = User.new(first_name: "Alex", last_name: "Johnson")

    assert_equal "Alex Johnson", user.full_name
  end

  test "username uniqueness is case insensitive" do
    User.create!(
      email: "first@example.com",
      username: "alex",
      first_name: "Alex",
      last_name: "Johnson",
      department: "Engineering",
      password: "password",
      password_confirmation: "password"
    )
    duplicate = User.new(
      email: "second@example.com",
      username: "ALEX",
      first_name: "Second",
      last_name: "User",
      department: "Design",
      password: "password",
      password_confirmation: "password"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:username], "has already been taken"
  end

  test "validates avatar type and size" do
    user = users(:one)
    user.avatar.attach(Rack::Test::UploadedFile.new(StringIO.new("not an image"), "text/plain", original_filename: "avatar.txt"))

    assert_not user.valid?
    assert_includes user.errors[:avatar], "must be a JPEG, PNG, or WebP image"
  end
end
