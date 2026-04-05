import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitBtn", "spinner"]

  submit(event) {
    if (!this.element.checkValidity()) return

    this.submitBtnTarget.disabled = true
    this.submitBtnTarget.classList.add("opacity-50", "cursor-not-allowed")
    this.spinnerTarget.classList.remove("hidden")

    // Disable all inputs to prevent resubmission
    this.element.querySelectorAll("input, button, select, textarea").forEach(el => {
      el.disabled = true
    })
  }
}
