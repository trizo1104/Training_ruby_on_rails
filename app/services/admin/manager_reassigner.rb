class Admin::ManagerReassigner
  def initialize(manager:, replacement_manager:)
    @manager = manager
    @replacement_manager = replacement_manager
  end

  def call
      # ActiveRecord::Base.transaction do
      reassign_employees!
      promote_replacement_manager!
    # end
  end

  private

  def reassign_employees!
    employees = @manager.employees.where.not(id: @replacement_manager.id)

    Employees::ReassignManager.new(
      employees: employees,
      manager: @replacement_manager
    ).call
  end

  def promote_replacement_manager!
    Users::PromoteToManager.new(
      user: @replacement_manager
    ).call
  end
end
