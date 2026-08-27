import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "role",
    "company",
    "manager",
    "managerContainer"
  ]

  static values = {
    managersUrl: String
  }

  connect() {
    this.updateManagerVisibility()
  }

  roleChanged() {
    this.updateManagerVisibility()
  }

  companyChanged() {
    this.updateManagers()
  }

  updateManagerVisibility() {
    const selectedRole =
      this.roleTarget.options[this.roleTarget.selectedIndex]?.text

    if (selectedRole === "Employee") {
      this.managerContainerTarget.classList.remove("hidden")
      this.managerTarget.disabled = false
      this.updateManagers()
    } else {
      this.managerContainerTarget.classList.add("hidden")
      this.managerTarget.disabled = true
      this.clearManagers()
    }
  }

  async updateManagers() {
    const companyId = this.companyTarget.value

    if (!companyId) {
      this.clearManagers()
      return
    }

    const url = new URL(
      this.managersUrlValue,
      window.location.origin
    )

    url.searchParams.set("company_id", companyId)

    const response = await fetch(url, {
      headers: {
        Accept: "application/json"
      }
    })

    if (!response.ok) {
      this.clearManagers()
      return
    }

    const managers = await response.json()

    this.managerTarget.innerHTML = ""

    const placeholder = document.createElement("option")
    placeholder.value = ""
    placeholder.textContent = "Select manager"

    this.managerTarget.appendChild(placeholder)

    managers.forEach((manager) => {
      const option = document.createElement("option")

      option.value = manager.id
      option.textContent = manager.name

      this.managerTarget.appendChild(option)
    })

    this.managerTarget.disabled = managers.length === 0
  }

  clearManagers() {
    this.managerTarget.innerHTML = ""

    const placeholder = document.createElement("option")
    placeholder.value = ""
    placeholder.textContent = "Select manager"

    this.managerTarget.appendChild(placeholder)

    this.managerTarget.disabled = true
  }
}