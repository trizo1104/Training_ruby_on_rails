class UserRoles::Synchronizer
  def initialize(user:, role_ids:)
    @user = user
    @role_ids = Array(role_ids).map(&:to_i) # shorten of .map { |role_id| role_id.to_i }
  end

  def call
    roles = Role.where(id: @role_ids)

    @user.roles = roles
  end
end
