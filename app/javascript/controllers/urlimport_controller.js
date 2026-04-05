import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "button", "buttonText", "spinner"]

  onSubmit(event) {
    const button = this.buttonTarget
    const buttonText = this.buttonTextTarget
    const spinner = this.spinnerTarget
    const form = this.formTarget

    if (!form.checkValidity()) {
      form.reportValidity()
      return
    }

    buttonText.classList.add("hidden")
    spinner.classList.remove("hidden")
    button.disabled = true

    form.submit()
  }
}
