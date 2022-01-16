import { Controller } from "@hotwired/stimulus"
import { Utils } from "../src/utils"

export default class extends Controller {
  static targets = ["deleteButtons", 
    "lightbox", "lightboximg", "lightboxlink"
  ]

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

  deleteShow() {
    this.deleteButtonsTargets.forEach(element => {
      element.classList.remove("hidden");
    });
  }

  deleteAbort() {
    console.log("deleteDialogClose");
    this.deleteButtonsTargets.forEach(element => {
      element.classList.add("hidden");
    });  
  }
  
  favorite() {
    var url = this.data.get("favorite-url");
    fetch(url, {
      method: 'put',
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

  lightboxOpen(event) {
    const imageurl = event.currentTarget.dataset.imageurl;
    this.lightboximgTarget.src = imageurl;
    this.lightboxlinkTarget.href = imageurl;
    this.lightboxTarget.classList.add("is-active");
  }

  lightboxClose() {
    this.lightboxTarget.classList.remove("is-active");
  }
}
