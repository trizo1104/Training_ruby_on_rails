class ApplicationMailer < ActionMailer::Base
  # default from: "from@example.com"
  default from: "no-reply@example.com"
  layout "mailer"
end
