import { Controller } from "@hotwired/stimulus"
import { Utils } from "../src/utils"

export default class extends Controller {
  static targets = ["dropzone", "fileInput", "spinner", "successMessage", "errorMessage", "resetButton"]
  static values = { url: String }

  connect() {
    this.maxFiles = 10
    this.acceptedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
    this.acceptedExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif']
  }

  // Drag and drop handlers
  dragenter(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.add('border-blue-500', 'bg-blue-50')
    this.dropzoneTarget.classList.remove('border-gray-300')
  }

  dragover(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  dragleave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.remove('border-blue-500', 'bg-blue-50')
    this.dropzoneTarget.classList.add('border-gray-300')
  }

  drop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.remove('border-blue-500', 'bg-blue-50')
    this.dropzoneTarget.classList.add('border-gray-300')
    
    const files = event.dataTransfer.files
    this.handleFiles(files)
  }

  // Click to select handler
  clickToSelect(event) {
    // Only trigger if clicking the dropzone itself or its children (not disabled)
    if (!this.dropzoneTarget.classList.contains('pointer-events-none')) {
      this.fileInputTarget.click()
    }
  }

  fileSelected(event) {
    const files = event.target.files
    this.handleFiles(files)
  }

  handleFiles(files) {
    // Hide any previous messages
    this.hideMessages()

    // Validate file count
    if (files.length > this.maxFiles) {
      this.showError(`Maximum ${this.maxFiles} files allowed. You selected ${files.length} files.`)
      return
    }

    // Validate file types
    const invalidFiles = []
    for (let i = 0; i < files.length; i++) {
      const file = files[i]
      const isValidType = this.acceptedTypes.includes(file.type) || 
                         this.acceptedExtensions.some(ext => file.name.toLowerCase().endsWith(ext))
      
      if (!isValidType) {
        invalidFiles.push(file.name)
      }
    }

    if (invalidFiles.length > 0) {
      this.showError(`Invalid file type(s): ${invalidFiles.join(', ')}. Please upload only image files (jpg, png, webp, heic, heif).`)
      return
    }

    // All validations passed, upload files
    this.uploadFiles(files)
  }

  uploadFiles(files) {
    // Hide dropzone
    this.dropzoneTarget.classList.add('hidden')

    // Show spinner
    this.spinnerTarget.classList.remove('hidden')

    // Create FormData
    const formData = new FormData()
    for (let i = 0; i < files.length; i++) {
      formData.append('files[]', files[i])
    }

    // Add AI method selection if present
    const aiMethodSelect = document.querySelector('select[name="ai_method"]')
    if (aiMethodSelect) {
      formData.append('ai_method', aiMethodSelect.value)
    }

    // Upload to server
    fetch(this.urlValue, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': Utils.getCsrfToken()
      },
      body: formData
    })
    .then(response => {
      this.spinnerTarget.classList.add('hidden')
      return response.json()
    })
    .then(data => {
      if (data.success) {
        // Redirect to new recipe page with pre-populated data
        if (data.redirect_url) {
          // Keep spinner visible during redirect
          if (typeof Turbo !== 'undefined') {
            Turbo.visit(data.redirect_url)
          } else {
            window.location.href = data.redirect_url
          }
        } else {
          this.showSuccess(data.message || 'Files uploaded successfully')
          this.resetButtonTarget.classList.remove('hidden')
          this.spinnerTarget.classList.add('hidden')
        }
      } else {
        this.spinnerTarget.classList.add('hidden')
        this.showError(data.error || 'Upload failed')
        this.enableDropzone()
      }
    })
    .catch(error => {
      this.spinnerTarget.classList.add('hidden')
      this.showError('Network error: ' + error.message)
      this.enableDropzone()
    })
  }

  reset() {
    // Hide messages and reset button
    this.hideMessages()
    this.resetButtonTarget.classList.add('hidden')

    // Clear file input
    this.fileInputTarget.value = ''

    // Re-enable dropzone
    this.enableDropzone()
  }

  enableDropzone() {
    this.dropzoneTarget.classList.remove('hidden')
  }

  hideMessages() {
    this.successMessageTarget.classList.add('hidden')
    this.errorMessageTarget.classList.add('hidden')
  }

  showSuccess(message) {
    this.successMessageTarget.textContent = message
    this.successMessageTarget.classList.remove('hidden')
  }

  showError(message) {
    this.errorMessageTarget.textContent = message
    this.errorMessageTarget.classList.remove('hidden')
  }
}
