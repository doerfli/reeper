import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "term", "tagslist" ]

  search() {
    var term = this.termTarget.value;
    var url = this.data.get("url") + "/" + encodeURI(term);;
    fetch(url, { credentials: 'same-origin'})
      .then(response => response.text())
      .then(html => {
        this.tagslistTarget.innerHTML = html
      })
  }
}