import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropzone", "previewContainer", "message"]
  static values = { maxFiles: Number, maxSize: Number }

  connect() {
    this.files = []
    this.dropzoneTarget.addEventListener("dragover", this.dragOver)
    this.dropzoneTarget.addEventListener("dragleave", this.dragLeave)
    this.dropzoneTarget.addEventListener("drop", this.drop)
    this.dropzoneTarget.addEventListener("keydown", this.activate)
  }

  disconnect() {
    this.dropzoneTarget.removeEventListener("dragover", this.dragOver)
    this.dropzoneTarget.removeEventListener("dragleave", this.dragLeave)
    this.dropzoneTarget.removeEventListener("drop", this.drop)
    this.dropzoneTarget.removeEventListener("keydown", this.activate)
    this.clearPreviews()
  }

  select = (event) => this.setFiles(Array.from(event.target.files))

  activate = (event) => {
    if (event.target !== this.dropzoneTarget || !["Enter", " "].includes(event.key)) return
    event.preventDefault()
    this.inputTarget.click()
  }

  dragOver = (event) => {
    event.preventDefault()
    this.dropzoneTarget.classList.add("border-sky-500", "bg-sky-50")
  }

  dragLeave = () => this.dropzoneTarget.classList.remove("border-sky-500", "bg-sky-50")

  drop = (event) => {
    event.preventDefault()
    this.dragLeave()
    this.setFiles(Array.from(event.dataTransfer.files))
  }

  setFiles(files) {
    this.clearMessage()
    const imageFiles = files.filter((file) => file.type.startsWith("image/"))
    if (imageFiles.length !== files.length) this.showMessage("Only image files can be uploaded.")

    const validFiles = imageFiles.filter((file) => {
      if (this.maxSizeValue && file.size > this.maxSizeValue) {
        this.showMessage(`Each file must be smaller than ${this.maxSizeValue / 1024 / 1024} MB.`)
        return false
      }
      return true
    })

    this.files = this.maxFilesValue === 1 ? validFiles.slice(0, 1) : [...this.files, ...validFiles]
    if (this.maxFilesValue && this.files.length > this.maxFilesValue) {
      this.files = this.files.slice(0, this.maxFilesValue)
      this.showMessage(`You can select at most ${this.maxFilesValue} files.`)
    }
    this.syncInput()
    this.renderPreviews()
  }

  remove(event) {
    this.files.splice(Number(event.currentTarget.dataset.index), 1)
    this.syncInput()
    this.renderPreviews()
  }

  syncInput() {
    const transfer = new DataTransfer()
    this.files.forEach((file) => transfer.items.add(file))
    this.inputTarget.files = transfer.files
  }

  renderPreviews() {
    this.clearPreviews()
    this.files.forEach((file, index) => {
      const url = URL.createObjectURL(file)
      const card = document.createElement("div")
      card.className = "flex items-center gap-3 rounded-xl border border-slate-200 bg-white p-2"
      card.innerHTML = `<img src="${url}" class="h-14 w-14 rounded-lg object-cover" alt="Selected image preview"><div class="min-w-0 flex-1"><p class="truncate text-sm font-medium text-slate-700"></p><p class="text-xs text-slate-500">${this.formatSize(file.size)}</p></div><button type="button" class="rounded-lg px-2 py-1 text-xs font-semibold text-rose-600 hover:bg-rose-50" data-index="${index}">Remove</button>`
      card.querySelector("p").textContent = file.name
      card.querySelector("button").addEventListener("click", (event) => this.remove(event))
      card.dataset.objectUrl = url
      this.previewContainerTarget.appendChild(card)
    })
  }

  clearPreviews() {
    if (!this.hasPreviewContainerTarget) return
    this.previewContainerTarget.querySelectorAll("[data-object-url]").forEach((node) => URL.revokeObjectURL(node.dataset.objectUrl))
    this.previewContainerTarget.replaceChildren()
  }

  clearMessage() {
    if (this.hasMessageTarget) this.messageTarget.textContent = ""
  }

  showMessage(message) {
    if (this.hasMessageTarget) this.messageTarget.textContent = message
  }

  formatSize(bytes) {
    return bytes < 1024 * 1024 ? `${Math.max(1, Math.round(bytes / 1024))} KB` : `${(bytes / 1024 / 1024).toFixed(1)} MB`
  }
}
