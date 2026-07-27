require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  test "defaults to assigned and requires content" do
    assignment = Assignment.new(user: users(:one))

    assert_equal "assigned", assignment.status
    assert_not assignment.valid?
    assert_includes assignment.errors[:content], "can't be blank"
  end

  test "images change status to finished and back to assigned" do
    assignment = assignments(:one)
    assignment.images.attach(upload("image/png", "one.png"))
    assignment.save!

    assignment.sync_status_with_images!
    assert_equal "finished", assignment.reload.status

    assignment.images.purge
    assignment.sync_status_with_images!
    assert_equal "assigned", assignment.reload.status
  end

  test "rejects unsupported image types" do
    assignment = assignments(:one)
    assignment.images.attach(upload("text/plain", "notes.txt"))

    assert_not assignment.valid?
    assert_includes assignment.errors[:images], "must be JPEG, PNG, or WebP files"
  end

  test "rejects more than ten images" do
    assignment = assignments(:one)
    11.times { |index| assignment.images.attach(upload("image/png", "#{index}.png")) }

    assert_not assignment.valid?
    assert_includes assignment.errors[:images], "You can upload at most 10 images"
  end

  private

  def upload(content_type, filename)
    Rack::Test::UploadedFile.new(StringIO.new("image data"), content_type, original_filename: filename)
  end
end
