class Admin::RbacUpdater
  def initialize (user_roles:, role_permissions:,  manager_replacements: {}, actor:)
    @user_roles = user_roles || {} # role id for each users
    @role_permissions = role_permissions || {} # permission id for each role
    @manager_replacements = manager_replacements || {} # user remove manager role and who is replace

    @actor = actor
    @changed_users = []
  end

  def call
    ActiveRecord::Base.transaction do
      sync_manager_replacements
      sync_user_roles
      sync_role_permissions
    end

    notify_changes
  end

  private

  def sync_user_roles
    @user_roles.each do |user_id, raw_role_ids|
      user = User.find(user_id)

      role_ids = Array(raw_role_ids)
        .reject(&:blank?) # remove blank values from the array
        .map(&:to_i)

      if manager_replacement_for?(user)
        role_ids -= [ manager_role.id ]
      end

      change = Admin::UserRoleUpdater.new(
        user: user,
        role_ids: role_ids
      ).call

      @changed_users << change if change
    end
  end

  def sync_role_permissions
    @role_permissions.each do |role_id, raw_permission_ids|
      role = Role.find(role_id)

      next unless role.editable?

      permission_ids = Array(raw_permission_ids)
        .reject(&:blank?)
        .map(&:to_i)

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

  def notify_changes
    @changed_users.each do |change|
      affected_user = change[:user]

     Permission::RoleChangedJob
     .set(wait: 1.minutes) # will be send mail after 1 min. (ex: wait_until: 10.minutes.from_now; wait_until: Time.zone.tomorrow.beginning_of_day)
     .perform_later(
      affected_user.id,
      @actor.id,
      change[:old_role_ids],
      change[:new_role_ids]
    )
    end
  end
end
