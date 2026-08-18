class AssignmentMailer < ApplicationMailer
  def submitted(assignment)
    @assignment = assignment
    @user = assignment.user

    @assignment.images.each do |image|
      resized_image =
        Assignments::ImageEncoder
          .new(image)
          .resized_for_email

      attachments.inline[image.filename.to_s] = {
        mime_type: image.content_type,
        content: resized_image
      }
    end

    I18n.with_locale(:en) do
      mail(to: @user.email, subject: I18n.t("mailers.assignment.submitted.subject"))
    end
  end
end


# class AssignmentMailer < ApplicationMailer
#   def submitted(assignment)
#     @assignment = assignment
#     @user = assignment.user

#     @assignment.images.each do |image|
#       resized_image =
#         Assignments::ImageEncoder
#           .new(image)
#           .resized_for_email
#       attachments[image.filename.to_s] = resized_image
#     end

#     mail(
#       to: @user.email,
#       subject: "Assignment submitted successfully"
#     )
#   end
# end
