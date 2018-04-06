import { Controller } from "stimulus"
import { Utils } from "../src/utils"

export default class extends Controller {
  static targets = [ "deleteDialog" ]

  delete() {
    // TODO: call delete and redirect to list
    var url = this.data.get("url");
    fetch(url, {
      method: 'delete',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': Utils.getCsrfToken()
      },
    }).then(function json(response) {
      return response.json()
    }).then(function(data) {
      Turbolinks.visit(data.redirect_url);
    });
  }

  deleteDialogShow() {
    this.deleteDialogTarget.classList.add("is-active");
  }

  deleteDialogClose() {
    this.deleteDialogTarget.classList.remove("is-active");
  }
}
