class Employees::ReassignManager
  def initialize(employees:, manager:)
    @employees = employees
    @manager = manager
  end

  def call
    @employees.update_all(manager_id: @manager.id)
  end
end
