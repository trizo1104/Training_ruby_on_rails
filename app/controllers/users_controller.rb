class UsersController < ApplicationController
  # before_action :authenticate_user!

  def index
    @page_title = t("users.index.page_title")
    @active_nav = "users"

    @users = policy_scope(User)
  end

  def show
    @user = current_user
    @page_title = t("users.show.page_title")
    @active_nav = "profile"
  end

  def edit
    @user = current_user
    @page_title = t("users.edit.page_title")
    @active_nav = "profile"
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      redirect_to profile_path, notice: t("flash.users.updated")
    else
      @page_title = t("users.edit.page_title")
      @active_nav = "profile"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:email, :username, :first_name, :last_name, :department, :avatar)
  end
end
