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
    // unless conflict, do not open modal
    if (this.conflictsValue.length === 0) {
      return
    }

    // handle each manager if they are removed at same time
    this.currentConflictIndex = 0
    this.open(this.conflictsValue[0])
  }

 

  open(conflict) {
    // save id user which is removed
    // this.userIdTarget.value = conflict.user_id

    // case 1: have another manager at same company
    if (conflict.replacement_managers.length > 0) {
      this.titleTarget.textContent =
        "Manager reassignment required"

      this.messageTarget.textContent =
        `${conflict.name} is being removed as a manager. Please select a replacement manager.`

      // show select
      this.replacementSectionTarget.classList.remove("hidden")

      // remove old options
      this.selectTarget.innerHTML = ""

      this.addManagers(
        conflict.replacement_managers
      )

      // able to confirm  
      this.enableConfirmButton()
    }

    // case 2: company just have one manager
    else {
      this.titleTarget.textContent =
        "Cannot remove manager"

      this.messageTarget.textContent =
        `${conflict.name} is the only manager in this company. You cannot remove this manager.`

      // do not show select
      this.replacementSectionTarget.classList.add("hidden")

      // disable to confirm.
      this.disableConfirmButton()
    }

    // Mở modal.
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

  close() {
    this.element.classList.add("hidden")
    this.element.classList.remove("flex")
  }


  confirm() {
    const conflict =
      this.conflictsValue[
        this.currentConflictIndex
      ]

    // can not submit of do not have any manager replace
    if (
      !conflict ||
      conflict.replacement_managers.length === 0
    ) {
      return
    }

    const replacementManagerId =
      this.selectTarget.value

    // Chưa chọn Manager => không submit.
    if (!replacementManagerId) {
      return
    }

   // do not submit form again, hidden into a form
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

    
    const input =
      document.createElement("input")

    input.type = "hidden"

    input.name =
      `manager_replacements[${conflict.user_id}]`

    input.value =
      replacementManagerId


    const formData = new FormData(rbacForm)

    console.log("===== FORM DATA BEFORE CONFIRM =====")

    for (const [key, value] of formData.entries()) {
      console.log(key, value)
    }

    console.log("====================================")  

    rbacForm.appendChild(input)

    rbacForm.requestSubmit()
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