import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "company",
    "manager"
  ]

  static values = {
    managersUrl: String
  }

  connect() {
    this.updateManagers()
  }

  companyChanged() {
    this.updateManagers()
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