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

  test "renders the image lightbox for assignment images" do
    assignment = assignments(:one)
    assignment.images.attach(upload("first.png"))
    assignment.save!

    get assignment_path(assignment)

    assert_response :success
    assert_select "[data-controller='image-lightbox']", count: 1
    assert_select "[data-image-lightbox-gallery] [data-action='click->image-lightbox#open']", count: 1
    assert_select "[data-image-lightbox-url]", count: 1
    assert_select "[data-image-lightbox-target='modal']", count: 1
  end

  test "serves attached images through active storage" do
    assignment = assignments(:one)
    assignment.images.attach(upload("first.png"))
    assignment.save!

    get rails_blob_path(assignment.images.first)

    assert_response :redirect
    assert_match %r{/rails/active_storage/disk/}, response.location
  end

  test "uses the same lightbox gallery on index and edit pages" do
    assignment = assignments(:one)
    assignment.images.attach([ upload("first.png"), upload("second.png") ])
    assignment.save!

    get assignments_path
    assert_select "[data-image-lightbox-gallery] [data-image-lightbox-url]", count: 2

    get edit_assignment_path(assignment)
    assert_select "[data-image-lightbox-gallery] [data-image-lightbox-url]", count: 2
  end

  test "profile updates only the current user" do
    patch profile_path, params: { user: { first_name: "Updated" } }

    assert_redirected_to profile_path
    assert_equal "Updated", users(:one).reload.first_name
    assert_equal "Second", users(:two).reload.first_name
  end

  private

  def upload(filename)
    Rack::Test::UploadedFile.new(StringIO.new("image data"), "image/png", original_filename: filename)
  end
end
