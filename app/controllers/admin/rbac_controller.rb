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
    # check if any employee belong to that manager
    conflicts = Admin::ManagerRoleChecker.new(
      user_roles: rbac_params[:user_roles],
      manager_replacements: rbac_params[:manager_replacements]
    ).call

    if conflicts.any?
      render_manager_conflict(conflicts)
      return
    end

    # if not -> continute do RBAC update
    Admin::RbacUpdater.new(
      user_roles: rbac_params[:user_roles],
      role_permissions: rbac_params[:role_permissions],
      manager_replacements: rbac_params[:manager_replacements]
    ).call

    # redirect when success
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
      role_permissions: {},
      manager_replacements: {}
    )
  end

  def role_params
    params.require(:role).permit(
      :name,
      :description
    )
  end

  def prepare_rbac_data
    @users = User
      .includes(:roles, :company, :manager)
      .order(:first_name, :last_name)

    @roles = Role
      .includes(:permissions)
      .order(:name)

    @permissions = Permission
      .order(:resource, :action)
      .group_by(&:resource)
  end

  def render_manager_conflict(conflicts)
    @manager_conflicts = conflicts
    @submitted_user_roles = rbac_params[:user_roles].to_h

    prepare_rbac_data

    render "users/index", status: :unprocessable_entity
  end
end
