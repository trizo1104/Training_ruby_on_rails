import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  // ============================================================
  // Users → Roles
  // ============================================================

  roleChanged(event) {
    const checkbox = event.currentTarget

    const row =
      checkbox.closest("[data-rbac-user-id]")

    if (!row) {
      return
    }

    this.updateUserRoleInputs(row)
  }

  updateUserRoleInputs(row) {
    const userId =
      row.dataset.rbacUserId

    const originalRoleIds =
      JSON.parse(
        row.dataset.rbacOriginalRoleIds
      )

    const currentRoleIds =
      Array.from(
        row.querySelectorAll(
          "[data-rbac-role-id]:checked"
        )
      ).map(
        checkbox =>
          Number(checkbox.dataset.rbacRoleId)
      )

    const changed =
      !this.sameRoles(
        originalRoleIds,
        currentRoleIds
      )

    this.removeUserRoleInputs(userId)

    if (!changed) {
      return
    }

    this.createUserRoleInputs(
      userId,
      currentRoleIds
    )
  }

  sameRoles(first, second) {
    const firstSorted =
      [...first].sort((a, b) => a - b)

    const secondSorted =
      [...second].sort((a, b) => a - b)

    return JSON.stringify(firstSorted) ===
           JSON.stringify(secondSorted)
  }

  removeUserRoleInputs(userId) {
    document
      .querySelectorAll(
        `[data-rbac-generated-user="${userId}"]`
      )
      .forEach(
        input => input.remove()
      )
  }

  createUserRoleInputs(userId, roleIds) {
    const form =
      document.querySelector("#rbac-form")

    if (!form) {
      console.error(
        "RBAC form not found."
      )

      return
    }

    roleIds.forEach(roleId => {
      const input =
        document.createElement("input")

      input.type = "hidden"

      input.name =
        `user_roles[${userId}][]`

      input.value = roleId

      input.dataset.rbacGeneratedUser =
        userId

      form.appendChild(input)
    })

    if (roleIds.length === 0) {
      const input =
        document.createElement("input")

      input.type = "hidden"

      input.name =
        `user_roles[${userId}][]`

      input.value = ""

      input.dataset.rbacGeneratedUser =
        userId

      form.appendChild(input)
    }
  }


  // ============================================================
  // Roles → Permissions
  // ============================================================

  permissionChanged(event) {
    const checkbox = event.currentTarget

    const roleId =
      checkbox.dataset.rbacPermissionRoleId

    if (!roleId) {
      return
    }

    const roleHeader =
      document.querySelector(
        `[data-rbac-role-id="${roleId}"][data-rbac-original-permission-ids]`
      )

    if (!roleHeader) {
      return
    }

    this.updateRolePermissionInputs(
      roleHeader
    )
  }

  updateRolePermissionInputs(roleHeader) {
    const roleId =
      roleHeader.dataset.rbacRoleId

    const originalPermissionIds =
      JSON.parse(
        roleHeader.dataset.rbacOriginalPermissionIds
      )

    const currentPermissionIds =
      Array.from(
        document.querySelectorAll(
          `[data-rbac-permission-role-id="${roleId}"][data-rbac-permission-id]:checked`
        )
      ).map(
        checkbox =>
          Number(checkbox.dataset.rbacPermissionId)
      )

    const changed =
      !this.samePermissions(
        originalPermissionIds,
        currentPermissionIds
      )

    this.removeRolePermissionInputs(
      roleId
    )

    if (!changed) {
      return
    }

    this.createRolePermissionInputs(
      roleId,
      currentPermissionIds
    )
  }

  samePermissions(first, second) {
    const firstSorted =
      [...first].sort((a, b) => a - b)

    const secondSorted =
      [...second].sort((a, b) => a - b)

    return JSON.stringify(firstSorted) ===
           JSON.stringify(secondSorted)
  }

  removeRolePermissionInputs(roleId) {
    document
      .querySelectorAll(
        `[data-rbac-generated-role="${roleId}"]`
      )
      .forEach(
        input => input.remove()
      )
  }

  createRolePermissionInputs(roleId, permissionIds) {
    const form =
      document.querySelector("#rbac-form")

    if (!form) {
      console.error(
        "RBAC form not found."
      )

      return
    }

    permissionIds.forEach(permissionId => {
      const input =
        document.createElement("input")

      input.type = "hidden"

      input.name =
        `role_permissions[${roleId}][]`

      input.value = permissionId

      input.dataset.rbacGeneratedRole =
        roleId

      form.appendChild(input)
    })

    if (permissionIds.length === 0) {
      const input =
        document.createElement("input")

      input.type = "hidden"

      input.name =
        `role_permissions[${roleId}][]`

      input.value = ""

      input.dataset.rbacGeneratedRole =
        roleId

      form.appendChild(input)
    }
  }
}