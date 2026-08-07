import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image", "caption", "previous", "next", "close"]

  connect() {
    this.items = []
    this.currentIndex = 0
    this.previousFocusedElement = null
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
    this.closeModal()
  }

  open(event) {
    event.preventDefault()

    const gallery = event.currentTarget.closest("[data-image-lightbox-gallery]")
    if (!gallery) return

    this.items = Array.from(gallery.querySelectorAll("[data-image-lightbox-url]"))
    this.currentIndex = Math.max(0, this.items.indexOf(event.currentTarget))
    this.previousFocusedElement = event.currentTarget
    this.renderCurrentImage()
    this.modalTarget.classList.remove("hidden")
    this.modalTarget.setAttribute("aria-hidden", "false")
    document.body.classList.add("overflow-hidden")
    requestAnimationFrame(() => this.closeTarget.focus())
  }

  // close(event) {
  //   if (event && event.target !== this.modalTarget) return

  //   this.closeModal()
  // }

  close() {
    this.closeModal()
  }

  previous(event) {
    event?.preventDefault()
    if (this.currentIndex > 0) {
      this.currentIndex -= 1
      this.renderCurrentImage()
    }
  }

  next(event) {
    event?.preventDefault()
    if (this.currentIndex < this.items.length - 1) {
      this.currentIndex += 1
      this.renderCurrentImage()
    }
  }

  handleKeydown(event) {
    if (this.modalTarget.classList.contains("hidden")) return

    if (event.key === "Escape") {
      event.preventDefault()
      this.closeModal()
    } else if (event.key === "ArrowLeft") {
      event.preventDefault()
      this.previous()
    } else if (event.key === "ArrowRight") {
      event.preventDefault()
      this.next()
    }
  }

  renderCurrentImage() {
    const item = this.items[this.currentIndex]
    if (!item) return

    this.imageTarget.src = item.dataset.imageLightboxUrl
    this.imageTarget.alt = item.dataset.imageLightboxAlt || "Assignment image"
    this.captionTarget.textContent = this.items.length > 1
      ? `Image ${this.currentIndex + 1} of ${this.items.length}`
      : "Assignment image"
    this.previousTarget.hidden = this.currentIndex === 0
    this.nextTarget.hidden = this.currentIndex === this.items.length - 1
  }

  closeModal() {
    if (!this.hasModalTarget || this.modalTarget.classList.contains("hidden")) return

    this.modalTarget.classList.add("hidden")
    this.modalTarget.setAttribute("aria-hidden", "true")
    document.body.classList.remove("overflow-hidden")
    this.previousFocusedElement?.focus()
    this.previousFocusedElement = null
  }
}
