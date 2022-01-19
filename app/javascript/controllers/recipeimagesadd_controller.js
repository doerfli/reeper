import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "files", "buttons", "template" ]

  add_another() {
    var t = this.templateTarget.cloneNode(true);
    // t.style.display = 'block';
    t.classList.remove("hidden");
    t.removeAttribute("data-target");
    this.filesTarget.insertBefore(t, this.buttonsTarget);
  }
}
