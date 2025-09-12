import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-rotation"
export default class extends Controller {
  static targets = ["image", "rotationInput"]
  static values = { rotation: Number }

  connect() {
    this.rotationValue = 0  // Always starts fresh at 0
  }

  rotateClockwise() {
    this.rotationValue = (this.rotationValue + 90) % 360
    this.updateRotation()
  }

  rotateCounterclockwise() {
    this.rotationValue = (this.rotationValue - 90 + 360) % 360
    this.updateRotation()
  }

  reset() {
    this.rotationValue = 0
    this.updateRotation()
  }

  updateRotation() {
    // Apply rotation to the canvas container
    if (this.hasImageTarget) {
      this.imageTarget.style.transform = `rotate(${this.rotationValue}deg)`
    }
    
    if (this.hasRotationInputTarget) {
      this.rotationInputTarget.value = this.rotationValue
    }
    
    // Dispatch event for OCR processing
    this.dispatch("rotated", { 
      detail: { rotation: this.rotationValue } 
    })
  }
}