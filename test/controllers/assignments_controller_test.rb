require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post user_session_path, params: { user: { email: users(:one).email, password: "password" } }
  end

  test "index only shows the signed in user's assignments" do
    get assignments_path

    assert_response :success
    assert_includes response.body, assignments(:one).content
    assert_not_includes response.body, assignments(:two).content
  end

  test "cannot view another user's assignment" do
    get assignment_path(assignments(:two))

    assert_response :not_found
  end

  test "creates an assignment for the current user" do
    assert_difference "Assignment.count", 1 do
      post assignments_path, params: { assignment: { content: "New work" } }
    end

    assert_redirected_to assignment_path(Assignment.order(:id).last)
    assert_equal users(:one), Assignment.order(:id).last.user
  end

  test "appends images when updating an assignment" do
    assignment = assignments(:one)
    assignment.images.attach(Rack::Test::UploadedFile.new(StringIO.new("first"), "image/png", original_filename: "first.png"))
    assignment.save!

    assert_difference -> { assignment.images.reload.count }, 1 do
      patch assignment_path(assignment), params: { assignment: { content: "Updated", images: [ Rack::Test::UploadedFile.new(StringIO.new("second"), "image/png", original_filename: "second.png") ] } }
    end

    assert_redirected_to assignment_path(assignment)
    assert_equal 2, assignment.images.reload.count
  end

  test "profile updates only the current user" do
    patch profile_path, params: { user: { first_name: "Updated" } }

    assert_redirected_to profile_path
    assert_equal "Updated", users(:one).reload.first_name
    assert_equal "Second", users(:two).reload.first_name
  end
end
