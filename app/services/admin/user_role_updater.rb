class Admin::UserRoleUpdater
  def initialize(user:, role_ids:)
    @user = user
    @requested_role_ids = Array(role_ids).map(&:to_i)
  end

  def call
    old_role_ids = current_role_ids
    new_role_ids = @requested_role_ids.sort

    return nil if old_role_ids == new_role_ids

    promote_to_manager_if_needed(old_role_ids, new_role_ids)

    UserRoles::Synchronizer.new(
      user: @user,
      role_ids: new_role_ids
    ).call

    {
      user: @user,
      old_role_ids: old_role_ids,
      new_role_ids: new_role_ids
    }
  end

  private

  def current_role_ids
    @user.roles.pluck(:id).sort
  end

  def promote_to_manager_if_needed(old_role_ids, new_role_ids)
    return unless new_role_ids.include?(manager_role.id)
    return if old_role_ids.include?(manager_role.id)

    Users::PromoteToManager.new(
      user: @user
    ).call
  end

  def manager_role
    @manager_role ||= Role.find_by!(name: "Manager")
  end
end
