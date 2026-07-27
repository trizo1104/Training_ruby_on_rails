class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @page_title = "Profile"
    @active_nav = "profile"
  end

  def edit
    @user = current_user
    @page_title = "Edit profile"
    @active_nav = "profile"
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      @page_title = "Edit profile"
      @active_nav = "profile"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:email, :username, :first_name, :last_name, :department, :avatar)
  end
end
