import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "modal", "modalImage", "counter", "prev", "next", "originalLink"]
  static values = { 
    images: Array,
    currentIndex: Number
  }

  connect() {
    this.currentIndexValue = 0
    this.imagesValue = this.imageTargets.map(img => ({
      src: img.dataset.fullUrl || img.src,
      alt: img.alt || "",
      caption: img.dataset.caption || "",
      originalUrl: img.dataset.originalUrl || img.dataset.fullUrl || img.src
    }))
    
    // Preload images for better performance
    this.preloadImages()
    
    // Bind keyboard events
    this.boundHandleKeydown = this.handleKeydown.bind(this)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  preloadImages() {
    this.imagesValue.forEach(imageData => {
      const img = new Image()
      img.src = imageData.src
    })
  }

  openLightbox(event) {
    const clickedImage = event.currentTarget
    this.currentIndexValue = this.imageTargets.indexOf(clickedImage)
    
    this.showModal()
    this.updateImage()
    this.updateCounter()
    this.updateNavigation()
    this.updateOriginalLink()
    
    // Add keyboard listener
    document.addEventListener("keydown", this.boundHandleKeydown)
    
    // Prevent body scroll
    document.body.style.overflow = "hidden"
  }

  closeLightbox() {
    this.hideModal()
    document.removeEventListener("keydown", this.boundHandleKeydown)
    document.body.style.overflow = ""
  }

  previousImage() {
    if (this.currentIndexValue > 0) {
      this.currentIndexValue--
      this.updateImage()
      this.updateCounter()
      this.updateNavigation()
      this.updateOriginalLink()
    }
  }

  nextImage() {
    if (this.currentIndexValue < this.imagesValue.length - 1) {
      this.currentIndexValue++
      this.updateImage()
      this.updateCounter()
      this.updateNavigation()
      this.updateOriginalLink()
    }
  }

  showModal() {
    this.modalTarget.classList.remove("invisible")
    // Trigger reflow to ensure transition works
    this.modalTarget.offsetHeight
    this.modalTarget.classList.add("lightbox-active")
  }

  hideModal() {
    this.modalTarget.classList.remove("lightbox-active")
    setTimeout(() => {
      this.modalTarget.classList.add("invisible")
    }, 300) // Match CSS transition duration
  }

  updateImage() {
    const currentImage = this.imagesValue[this.currentIndexValue]
    this.modalImageTarget.src = currentImage.src
    this.modalImageTarget.alt = currentImage.alt
    
    // Add loading state
    this.modalImageTarget.classList.add("loading")
    this.modalImageTarget.onload = () => {
      this.modalImageTarget.classList.remove("loading")
    }
  }

  updateCounter() {
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.currentIndexValue + 1} / ${this.imagesValue.length}`
    }
  }

  updateNavigation() {
    if (this.hasPrevTarget) {
      this.prevTarget.style.display = this.currentIndexValue === 0 ? "none" : "block"
    }
    if (this.hasNextTarget) {
      this.nextTarget.style.display = this.currentIndexValue === this.imagesValue.length - 1 ? "none" : "block"
    }
  }

  updateOriginalLink() {
    if (this.hasOriginalLinkTarget) {
      const currentImage = this.imagesValue[this.currentIndexValue]
      this.originalLinkTarget.href = currentImage.originalUrl
    }
  }

  handleKeydown(event) {
    switch(event.key) {
      case "Escape":
        this.closeLightbox()
        break
      case "ArrowLeft":
        this.previousImage()
        break
      case "ArrowRight":
        this.nextImage()
        break
    }
  }

  // Handle clicking outside the image
  handleBackdropClick(event) {
    if (event.target === this.modalTarget) {
      this.closeLightbox()
    }
  }
}
