import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "term", "list" ]

  search() {
    var term = this.termTarget.value;
    var url = this.data.get("url") + "/" + encodeURI(term);;
    fetch(url, { credentials: 'same-origin'})
      .then(response => response.text())
      .then(html => {
        this.listTarget.innerHTML = html
      })
  }
}