import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu"]

  connect() {
    this.close = this.close.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener("click", this.close)
    document.addEventListener("keydown", this.closeOnEscape)
  }

  disconnect() {
    document.removeEventListener("click", this.close)
    document.removeEventListener("keydown", this.closeOnEscape)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
    this.buttonTarget.setAttribute("aria-expanded", String(this.isOpen))
  }

  close(event) {
    if (this.element.contains(event.target)) return

    this.hide()
  }

  closeOnEscape(event) {
    if (event.key !== "Escape") return

    this.hide()
  }

  hide() {
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  get isOpen() {
    return !this.menuTarget.classList.contains("hidden")
  }
}
