class RolePermissions::Synchronizer
  def initialize(role:, permission_ids:)
    @role = role
    @permission_ids = Array(permission_ids).map(&:to_i)
  end

  def call
    permissions = Permission.where(id: @permission_ids)

    @role.permissions = permissions
  end
end
