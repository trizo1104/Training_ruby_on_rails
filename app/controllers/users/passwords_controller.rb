module Users
  class PasswordsController < Devise::PasswordsController
    layout "authentication"
  end
end
