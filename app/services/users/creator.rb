class Users::Creator
  def initialize(
    user:,
    role:,
    company: nil,
    manager: nil
  )
    @user = user
    @role = role
    @company = company
    @manager = manager
  end

  def call
    User.transaction do
      assign_relationships
      @user.save!

      @user.roles = [ @role ]
    end

    @user
  end

  private

  def assign_relationships
    @user.company = @company
    @user.manager = @manager
  end
end
