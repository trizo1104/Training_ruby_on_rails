import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    inputId: String
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,

      onEnd: () => { // run when the user drops an item in a new position
        const ids = [...this.element.children].map(
          (element) => element.dataset.sortableId
        )

        this.updateHiddenInput(ids)
      }
    })
  }

   updateHiddenInput(ids) { 
    const input = document.getElementById(this.inputIdValue)

    if (!input) return

    input.value = ids.join(",")
  }

  disconnect() {
    this.sortable?.destroy()
  }
}