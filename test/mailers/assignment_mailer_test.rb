require "test_helper"

class AssignmentMailerTest < ActionMailer::TestCase
  test "assignment email remains English when the interface locale is Vietnamese" do
    I18n.with_locale(:vi) do
      email = AssignmentMailer.submitted(assignments(:one))

      assert_equal "Assignment submitted successfully", email.subject
      assert_includes email.body.encoded, "Hello"
      assert_includes email.body.encoded, "Assignment content"
    end
  end
end
