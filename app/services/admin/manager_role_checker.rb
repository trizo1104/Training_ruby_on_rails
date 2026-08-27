class Admin::ManagerRoleChecker
  def initialize(user_roles:)
    @user_roles = user_roles || {}
  end

  def call
    User
      .joins(:roles)
      .where(roles: { name: "Manager" })
      .distinct
      .filter_map do |user|
        next unless manager_role_removed?(user)

        employees = user.employees.to_a
        next if employees.empty?

        {
          user_id: user.id,
          name: user.full_name,
          company_id: user.company_id,
          employee_count: employees.size,
          replacement_managers: replacement_managers_for(user),
          replacement_employees: replacement_employees_for(employees)
        }
      end
  end

  private

  def manager_role_removed?(user)
    submitted_role_ids = Array(
      @user_roles[user.id.to_s]
    ).map(&:to_i)

    !submitted_role_ids.include?(manager_role.id)
  end

  def replacement_managers_for(user)
    User
      .joins(:roles)
      .where(
        company_id: user.company_id,
        roles: { name: "Manager" }
      )
      .where.not(id: user.id)
      .distinct
      .order(:first_name, :last_name)
      .map do |manager|
        {
          id: manager.id,
          name: manager.full_name
        }
      end
  end

  def replacement_employees_for(employees)
    employees
      .sort_by { |employee| [ employee.first_name, employee.last_name ] }
      .map do |employee|
        {
          id: employee.id,
          name: employee.full_name
        }
      end
  end

  def manager_role
    @manager_role ||= Role.find_by!(name: "Manager")
  end
end
