import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

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

    /*
     * Important:
     *
     * If the admin removes ALL roles,
     * we still need to tell Rails that
     * this user was changed.
     *
     * Therefore we send one empty value.
     */
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
}