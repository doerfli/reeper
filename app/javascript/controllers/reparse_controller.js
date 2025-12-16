import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "buttonText", "spinner"]

  onSubmit(event) {
    const form = event.target
    const button = form.querySelector('[data-reparse-target="button"]')
    
    if (button) {
      // Find the button text and spinner within this specific button
      const buttonText = button.querySelector('[data-reparse-target="buttonText"]')
      const spinner = button.querySelector('[data-reparse-target="spinner"]')
      
      if (buttonText && spinner) {
        // Hide button text, show spinner
        buttonText.classList.add("hidden")
        spinner.classList.remove("hidden")
        
        // Disable the button to prevent double-clicks
        button.disabled = true
      }
    }
    
    // Allow form submission to proceed
  }
}
