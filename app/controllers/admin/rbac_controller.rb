class Admin::RbacController < ApplicationController
  before_action :authorize_rbac!

  def show
    @users = User
      .includes(:roles, :company, :manager)
      .order(:first_name, :last_name)

    @roles = Role
      .includes(:permissions)
      .order(:name)

    @permissions = Permission
      .order(:resource, :action)
  end

  def update
    Admin::RbacUpdater.new(
      user_roles: rbac_params[:user_roles],
      role_permissions: rbac_params[:role_permissions]
    ).call

    redirect_to users_path,
                notice: "RBAC updated successfully."
  end

  def create_role
    role = Role.create!(
      name: role_params[:name],
      description: role_params[:description]
    )

    redirect_to users_path,
                notice: "Role #{role.name} created successfully."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to users_path,
                alert: e.record.errors.full_messages.to_sentence
  end

  private

  def authorize_rbac!
    authorize current_user, :manage_rbac?
  end

  def rbac_params
    params.permit(
      user_roles: {},
      role_permissions: {}
    )
  end

  def role_params
    params.require(:role).permit(
      :name,
      :description
    )
  end
end
