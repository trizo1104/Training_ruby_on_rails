# This file should ensure the existence of records required to run the application in every environment.
# The code here should be idempotent.

# ============================================================
# Permissions
# ============================================================

permissions = [
  [ "company", "create" ],
  [ "company", "read" ],
  [ "company", "update" ],
  [ "company", "delete" ],

  [ "user", "create" ],
  [ "user", "read" ],
  [ "user", "update" ],
  [ "user", "delete" ],

  [ "assignment", "create" ],
  [ "assignment", "read" ],
  [ "assignment", "update" ],
  [ "assignment", "delete" ]
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

# Admin
# Admin has every permission.

admin_role.permissions = Permission.all


# Manager

manager_permissions = [
  [ "company", "view" ],

  [ "user", "create" ],
  [ "user", "view" ],
  [ "user", "update" ],

  [ "assignment", "create" ],
  [ "assignment", "view" ],
  [ "assignment", "update" ],
  [ "assignment", "delete" ]
]

manager_role.permissions = manager_permissions.map do |resource, action|
  Permission.find_by!(
    resource: resource,
    action: action
  )
end


# Employee

employee_permissions = [
  [ "assignment", "create" ],
  [ "assignment", "view" ],
  [ "assignment", "update" ]
]

employee_role.permissions = employee_permissions.map do |resource, action|
  Permission.find_by!(
    resource: resource,
    action: action
  )
end
