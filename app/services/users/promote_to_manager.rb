class Users::PromoteToManager
  def initialize(user:)
    @user = user
  end

  def call
    @user.update!(manager_id: nil)
  end
end
