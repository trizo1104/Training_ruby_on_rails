class Admin::RbacUpdater
  def initialize (user_roles:, role_permissions:,  manager_replacements: {})
    @user_roles = user_roles || {} # role id for each users
    @role_permissions = role_permissions || {} # permission id for each role
    @manager_replacements = manager_replacements || {} # user remove manager role and who is replace
  end

  def call
    ActiveRecord::Base.transaction do
      sync_manager_replacements
      sync_user_roles
      sync_role_permissions
    end
  end

  private

  def sync_user_roles
    User.find_each do |user|
      role_ids = Array(@user_roles[user.id.to_s]).map(&:to_i)

      if manager_replacement_for?(user)
        role_ids -= [ manager_role.id ]
      end

      UserRoles::Synchronizer.new(
        user: user,
        role_ids: role_ids
      ).call
    end
  end

  def sync_role_permissions
    Role.find_each do |role|
      permission_ids = Array(@role_permissions[role.id.to_s]).map(&:to_i)

      RolePermissions::Synchronizer.new(
        role: role,
        permission_ids: permission_ids
      ).call
    end
  end

  def sync_manager_replacements
    return if @manager_replacements.blank?

    @manager_replacements.each do |manager_id, replacement_manager_id|
      # old manager
      manager = User.find(manager_id)

      # new manager
      replacement_manager = User.find(
        replacement_manager_id
      )

      Admin::ManagerReassigner.new(
        manager: manager,
        replacement_manager: replacement_manager
      ).call
    end
  end

  def manager_replacement_for?(user)
    @manager_replacements.key?(user.id.to_s)
  end

  def manager_role
    @manager_role ||= Role.find_by!(name: "Manager")
  end
end
