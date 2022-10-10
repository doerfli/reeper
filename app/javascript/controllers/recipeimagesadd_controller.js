import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "files", "buttons", "template", "saveButton", "spinner", "form" ]

  add_another() {
    var t = this.templateTarget.cloneNode(true);
    // t.style.display = 'block';
    t.classList.remove("hidden");
    t.removeAttribute("data-recipeimagesadd-target");
    this.filesTarget.insertBefore(t, this.buttonsTarget);
  }

  save(event) {
    event.preventDefault();
    this.saveButtonTarget.disabled = true;
    const altText = this.saveButtonTarget.dataset.alttext;
    this.saveButtonTarget.innerHTML = altText;
    this.spinnerTarget.classList.remove("hidden");
    this.formTarget.submit();
  }
}
