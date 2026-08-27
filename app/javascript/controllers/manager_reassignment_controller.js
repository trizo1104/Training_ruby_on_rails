import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form",
    "userId",
    "title",
    "message",
    "select"
  ]

  static values = {
    conflicts: Array
  }

  connect() {
    if (this.conflictsValue.length === 0) {
      return
    }

    this.currentConflictIndex = 0
    this.open(this.conflictsValue[0])
  }

  open(conflict) {
    this.userId = conflict.user_id
    this.companyId = conflict.company_id

    this.titleTarget.textContent =
      "Manager reassignment required"

    this.messageTarget.textContent =
      `${conflict.name} currently has ${conflict.employee_count} employees. Please select a replacement manager.`

    this.selectTarget.innerHTML = ""

    if (conflict.replacement_managers.length > 0) {
      this.addManagers(
        conflict.replacement_managers
      )
    } else {
      this.messageTarget.textContent =
        `${conflict.name} currently has ${conflict.employee_count} employees, but there are no other managers in this company. Please select an employee to become the new manager.`

      this.addEmployees(
        conflict.replacement_employees
      )
    }

    this.element.classList.remove("hidden")
    this.element.classList.add("flex")
  }

  addManagers(managers) {
    const placeholder = document.createElement("option")

    placeholder.value = ""
    placeholder.textContent = "Select a manager"
    placeholder.disabled = true
    placeholder.selected = true

    this.selectTarget.appendChild(placeholder)

    managers.forEach(manager => {
      const option = document.createElement("option")

      option.value = manager.id
      option.textContent = manager.name

      this.selectTarget.appendChild(option)
    })
  }

  addEmployees(employees) {
    const placeholder = document.createElement("option")

    placeholder.value = ""
    placeholder.textContent = "Select an employee"
    placeholder.disabled = true
    placeholder.selected = true

    this.selectTarget.appendChild(placeholder)

    employees.forEach(employee => {
      const option = document.createElement("option")

      option.value = employee.id
      option.textContent = employee.name

      this.selectTarget.appendChild(option)
    })
  }

  close() {
    this.element.classList.add("hidden")
    this.element.classList.remove("flex")
  }

  confirm() {
  const replacementManagerId =
    this.selectTarget.value

  if (!replacementManagerId) {
    return
  }

  this.userIdTarget.value =
    this.conflictsValue[
      this.currentConflictIndex
    ].user_id

  this.formTarget.submit()
}
}