# This file should ensure the existence of records required to run the application
# in every environment.
# The code here should be idempotent.


# ============================================================
# Permissions
# ============================================================

permissions = [
  # Company
  [ "company", "view" ],
  [ "company", "create" ],
  [ "company", "update" ],
  [ "company", "delete" ],
  [ "company", "view_all" ],

  # User
  [ "user", "view" ],
  [ "user", "create" ],
  [ "user", "update" ],
  [ "user", "delete" ],
  [ "user", "assign_role" ],
  [ "user", "view_all" ],

  # Assignment
  [ "assignment", "view" ],
  [ "assignment", "create" ],
  [ "assignment", "update" ],
  [ "assignment", "delete" ],

  # Role
  [ "role", "view" ],
  [ "role", "create" ],
  [ "role", "update" ],
  [ "role", "delete" ],
  [ "role", "assign_permission" ],

  # rbac
  [ "rbac", "manage" ]
]

permissions.each do |resource, action|
  Permission.find_or_create_by!(
    resource: resource,
    action: action
  )
end


# ============================================================
# Roles
# ============================================================

admin_role = Role.find_or_create_by!(name: "Admin") do |role|
  role.description = "Full system access"
end

manager_role = Role.find_or_create_by!(name: "Manager") do |role|
  role.description = "Manage employees in their company"
end

employee_role = Role.find_or_create_by!(name: "Employee") do |role|
  role.description = "Employee access"
end


# ============================================================
# Role Permissions
# ============================================================

# ------------------------------------------------------------
# Admin
# ------------------------------------------------------------

admin_role.permissions = Permission.all


# ------------------------------------------------------------
# Manager
# ------------------------------------------------------------

manager_permissions = [
  [ "company", "view" ],

  [ "user", "view" ],
  [ "user", "create" ],
  [ "user", "update" ],

  [ "assignment", "view" ],
  [ "assignment", "create" ],
  [ "assignment", "update" ],
  [ "assignment", "delete" ]
]

manager_role.permissions = manager_permissions.map do |resource, action|
  Permission.find_by!(
    resource: resource,
    action: action
  )
end


# ------------------------------------------------------------
# Employee
# ------------------------------------------------------------

employee_permissions = [
  [ "assignment", "view" ],
  [ "assignment", "create" ],
  [ "assignment", "update" ]
]

employee_role.permissions = employee_permissions.map do |resource, action|
  Permission.find_by!(
    resource: resource,
    action: action
  )
end


# ============================================================
# Companies
# ============================================================

company_a = Company.find_or_create_by!(
  name: "Company A"
) do |company|
  company.address = "123 Nguyen Hue, Ho Chi Minh City"
end

company_b = Company.find_or_create_by!(
  name: "Company B"
) do |company|
  company.address = "456 Le Loi, Ho Chi Minh City"
end


# ============================================================
# Users
# ============================================================

PASSWORD = "123456"


# ------------------------------------------------------------
# Admin
# ------------------------------------------------------------

admin = User.find_or_create_by!(
  email: "admin@example.com"
) do |user|
  user.username = "admin"
  user.first_name = "System"
  user.last_name = "Admin"
  user.department = "IT"
  user.password = PASSWORD
  user.password_confirmation = PASSWORD
end

admin.update!(
  company: nil,
  manager: nil
)

UserRole.find_or_create_by!(
  user: admin,
  role: admin_role
)


# ------------------------------------------------------------
# Manager A
# ------------------------------------------------------------

manager_a = User.find_or_create_by!(
  email: "manager.a@example.com"
) do |user|
  user.username = "manager_a"
  user.first_name = "John"
  user.last_name = "Manager"
  user.department = "Management"
  user.password = PASSWORD
  user.password_confirmation = PASSWORD
end

manager_a.update!(
  company: company_a,
  manager: nil
)

UserRole.find_or_create_by!(
  user: manager_a,
  role: manager_role
)


# ------------------------------------------------------------
# Manager B
# ------------------------------------------------------------

manager_b = User.find_or_create_by!(
  email: "manager.b@example.com"
) do |user|
  user.username = "manager_b"
  user.first_name = "Jane"
  user.last_name = "Manager"
  user.department = "Management"
  user.password = PASSWORD
  user.password_confirmation = PASSWORD
end

manager_b.update!(
  company: company_b,
  manager: nil
)

UserRole.find_or_create_by!(
  user: manager_b,
  role: manager_role
)


# ------------------------------------------------------------
# Employee A1
# ------------------------------------------------------------

employee_a1 = User.find_or_create_by!(
  email: "employee.a1@example.com"
) do |user|
  user.username = "employee_a1"
  user.first_name = "Alice"
  user.last_name = "Employee"
  user.department = "Production"
  user.password = PASSWORD
  user.password_confirmation = PASSWORD
end

employee_a1.update!(
  company: company_a,
  manager: manager_a
)

UserRole.find_or_create_by!(
  user: employee_a1,
  role: employee_role
)


# ------------------------------------------------------------
# Employee A2
# ------------------------------------------------------------

employee_a2 = User.find_or_create_by!(
  email: "employee.a2@example.com"
) do |user|
  user.username = "employee_a2"
  user.first_name = "Bob"
  user.last_name = "Employee"
  user.department = "Production"
  user.password = PASSWORD
  user.password_confirmation = PASSWORD
end

employee_a2.update!(
  company: company_a,
  manager: manager_a
)

UserRole.find_or_create_by!(
  user: employee_a2,
  role: employee_role
)


# ------------------------------------------------------------
# Employee B1
# ------------------------------------------------------------

employee_b1 = User.find_or_create_by!(
  email: "employee.b1@example.com"
) do |user|
  user.username = "Charlie"
  user.first_name = "Charlie"
  user.last_name = "Employee"
  user.department = "Production"
  user.password = PASSWORD
  user.password_confirmation = PASSWORD
end

employee_b1.update!(
  company: company_b,
  manager: manager_b
)

UserRole.find_or_create_by!(
  user: employee_b1,
  role: employee_role
)


# ============================================================
# Summary
# ============================================================

puts
puts "============================================"
puts "Seed completed successfully!"
puts "============================================"
