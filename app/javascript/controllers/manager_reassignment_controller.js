import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [
    "title",
    "message",
    "select",
    "replacementSection",
    "confirmButton"
  ]

  static values = {
    conflicts: Array
  }

  connect() {
    if (this.conflictsValue.length === 0) {
      return
    }

    this.currentConflictIndex = 0
    this.replacements = {}

    this.openCurrentConflict()
  }

  openCurrentConflict() {
    const conflict =
      this.conflictsValue[this.currentConflictIndex]

    if (!conflict) {
      return
    }

    this.element.classList.remove("hidden")
    this.element.classList.add("flex")

    this.titleTarget.textContent =
      "Manager reassignment required"

    this.messageTarget.textContent =
      `${conflict.name} is being removed as a manager. Please select a replacement manager.`

    this.replacementSectionTarget.classList.remove("hidden")

    this.selectTarget.innerHTML = ""

    this.addManagers(
      conflict.replacement_managers
    )

    this.updateConfirmButton()
    this.updateButtonText()
}

  addManagers(managers) {
    const placeholder =
      document.createElement("option")

    placeholder.value = ""
    placeholder.textContent =
      "Select a manager"

    placeholder.disabled = true
    placeholder.selected = true

    this.selectTarget.appendChild(
      placeholder
    )

    managers.forEach(manager => {
      const option =
        document.createElement("option")

      option.value = manager.id
      option.textContent = manager.name

      this.selectTarget.appendChild(option)
    })
  }

  confirm() {
    const conflict =
      this.conflictsValue[
        this.currentConflictIndex
      ]

    if (!conflict) {
      return
    }

    const replacementManagerId =
      this.selectTarget.value

    if (!replacementManagerId) {
      return
    }

    // Store replacement temporarily.
    this.replacements[conflict.user_id] =
      replacementManagerId

    this.currentConflictIndex++

    // More conflicts remain.
    if (
      this.currentConflictIndex <
      this.conflictsValue.length
    ) {
      this.openCurrentConflict()
      return
    }

    // All conflicts have been resolved.
    this.submitForm()
  }

  submitForm() {
    const rbacForm =
      document.querySelector(
        "form[data-rbac-form]"
      )

    if (!rbacForm) {
      console.error(
        "RBAC form not found."
      )

      return
    }

    Object.entries(this.replacements)
      .forEach(
        ([managerId, replacementManagerId]) => {
          const input =
            document.createElement("input")

          input.type = "hidden"

          input.name =
            `manager_replacements[${managerId}]`

          input.value =
            replacementManagerId

          rbacForm.appendChild(input)
        }
      )

    rbacForm.requestSubmit()
  }

  cancel() {
    // Cancel the entire current RBAC change.
    window.location.reload()
  }

  close() {
    this.cancel()
  }

  updateConfirmButton() {
    const conflict =
      this.conflictsValue[
        this.currentConflictIndex
      ]

    if (
      !conflict ||
      conflict.replacement_managers.length === 0
    ) {
      this.disableConfirmButton()
      return
    }

    this.enableConfirmButton()
  }

  updateButtonText() {
    const button =
      this.element.querySelector(
        '[data-action~="manager-reassignment#confirm"]'
      )

    if (!button) {
      return
    }

    const isLastConflict =
      this.currentConflictIndex ===
      this.conflictsValue.length - 1

    button.textContent =
      isLastConflict
        ? "Confirm"
        : "Next"
  }

  disableConfirmButton() {
    const button =
      this.element.querySelector(
        '[data-action~="manager-reassignment#confirm"]'
      )

    if (!button) {
      return
    }

    button.disabled = true

    button.classList.add(
      "cursor-not-allowed",
      "opacity-50"
    )
  }

  enableConfirmButton() {
    const button =
      this.element.querySelector(
        '[data-action~="manager-reassignment#confirm"]'
      )

    if (!button) {
      return
    }

    button.disabled = false

    button.classList.remove(
      "cursor-not-allowed",
      "opacity-50"
    )
  }
}