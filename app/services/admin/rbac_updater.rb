class Admin::RbacUpdater
  def initialize (user_roles:, role_permissions:)
    @user_roles = user_roles || {}
    @role_permissions = role_permissions || {}
  end

  def call
    ActiveRecord::Base.transaction do
      sync_user_roles
      sync_role_permissions
    end
  end

  private

  def sync_user_roles
    User.find_each do |user|
      role_ids = Array(@user_roles[user.id.to_s])

      UserRoles::Synchronizer.new(
        user: user,
        role_ids: role_ids
      ).call
    end
  end

  def sync_role_permissions
    Role.find_each do |role|
      permission_ids = Array(@role_permissions[role.id.to_s])

      RolePermissions::Synchronizer.new(
        role: role,
        permission_ids: permission_ids
      ).call
    end
  end
end
