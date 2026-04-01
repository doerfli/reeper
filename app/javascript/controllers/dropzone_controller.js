import { Controller } from "@hotwired/stimulus"
import { Utils } from "../src/utils"

export default class extends Controller {
  static targets = ["dropzone", "fileInput", "spinner", "successMessage", "errorMessage", "resetButton", "previewContainer", "uploadButton"]
  static values = { url: String, previewMode: Boolean }

  connect() {
    this.maxFiles = 10
    this.acceptedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
    this.acceptedExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.heic', '.heif']
    this.pendingFiles = []
    this.pendingObjectUrls = []
    
    // Initialize button state in preview mode
    if (this.previewModeValue && this.hasUploadButtonTarget) {
      this.uploadButtonTarget.disabled = true
    }
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

    // Validate file count (account for already-queued files in preview mode)
    const totalCount = this.previewModeValue ? this.pendingFiles.length + files.length : files.length
    if (totalCount > this.maxFiles) {
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

    if (this.previewModeValue) {
      for (let i = 0; i < files.length; i++) {
        this.pendingFiles.push(files[i])
      }
      this.renderPreviews()
      this.uploadButtonTarget.disabled = false
    } else {
      // All validations passed, upload files
      this.uploadFiles(files)
    }
  }

  renderPreviews() {
    // Revoke old object URLs before rebuilding
    this.pendingObjectUrls.forEach(url => URL.revokeObjectURL(url))
    this.pendingObjectUrls = []

    if (this.pendingFiles.length === 0) {
      this.previewContainerTarget.classList.add('hidden')
      this.previewContainerTarget.innerHTML = ''
      return
    }

    this.previewContainerTarget.classList.remove('hidden')

    const grid = document.createElement('div')
    grid.className = 'grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3 mt-4'

    this.pendingFiles.forEach((file, index) => {
      const objectUrl = URL.createObjectURL(file)
      this.pendingObjectUrls.push(objectUrl)

      const card = document.createElement('div')
      card.className = 'relative rounded-lg overflow-hidden border border-gray-200 bg-gray-50'
      card.innerHTML = `
        <img src="${objectUrl}" alt="${this.escapeHtml(file.name)}" class="w-full h-24 object-cover">
        <div class="px-2 py-1 text-xs text-gray-600 truncate">${this.escapeHtml(file.name)}</div>
        <button type="button"
                class="absolute top-1 right-1 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center hover:bg-red-600"
                data-action="click->dropzone#removeFile"
                data-index="${index}"
                aria-label="Remove">
          <i class="fas fa-times text-xs pointer-events-none"></i>
        </button>
        ${index === 0 ? '<div class="absolute top-1 left-1 bg-blue-500 text-white text-xs rounded px-1 leading-5">AI</div>' : ''}
      `
      grid.appendChild(card)
    })

    this.previewContainerTarget.innerHTML = ''
    this.previewContainerTarget.appendChild(grid)
  }

  removeFile(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    this.pendingFiles.splice(index, 1)

    if (this.pendingFiles.length === 0) {
      this.uploadButtonTarget.disabled = true
      this.pendingObjectUrls.forEach(url => URL.revokeObjectURL(url))
      this.pendingObjectUrls = []
      this.previewContainerTarget.classList.add('hidden')
      this.previewContainerTarget.innerHTML = ''
    } else {
      this.renderPreviews()
    }
  }

  submit() {
    const filesToUpload = this.pendingFiles.slice()
    this.pendingFiles = []
    this.uploadButtonTarget.disabled = true
    this.previewContainerTarget.classList.add('hidden')
    this.uploadFiles(filesToUpload)
  }

  escapeHtml(str) {
    return str.replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]))
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

    // Clear any pending preview state
    this.pendingFiles = []
    this.pendingObjectUrls.forEach(url => URL.revokeObjectURL(url))
    this.pendingObjectUrls = []
    if (this.hasPreviewContainerTarget) {
      this.previewContainerTarget.classList.add('hidden')
      this.previewContainerTarget.innerHTML = ''
    }
    if (this.hasUploadButtonTarget) {
      this.uploadButtonTarget.classList.add('hidden')
    }

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
