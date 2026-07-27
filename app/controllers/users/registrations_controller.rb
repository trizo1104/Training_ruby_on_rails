module Users
  class RegistrationsController < Devise::RegistrationsController
    layout "authentication"

    protected

    def sign_up_params
      params.require(:user).permit(
        :email, :username, :first_name, :last_name, :department,
        :password, :password_confirmation
      )
    end

    def account_update_params
      params.require(:user).permit(
        :email, :username, :first_name, :last_name, :department,
        :password, :password_confirmation, :current_password
      )
    end
  end
end
