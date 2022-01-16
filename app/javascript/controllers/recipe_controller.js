import { Controller } from "@hotwired/stimulus"
import { Utils } from "../src/utils"

export default class extends Controller {
  static targets = ["deleteDialog", "editbuttons", "editoff", "editon", "lightbox", "lightboximg", "lightboxlink"]

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

  toggleeditbuttons() {
    var editstate = this.data.get("editstate");
    console.log(editstate);
    if ( editstate == "false" ) {
      this.editbuttonsTargets.forEach(element => {
        element.classList.remove("hidden")
      });
      this.editonTarget.classList.add("hidden");
      this.editoffTarget.classList.remove("hidden");
      this.data.set("editstate", "true");
    } else {
      this.editbuttonsTargets.forEach(element => {
        element.classList.add("hidden")
      });
      this.editonTarget.classList.remove("hidden");
      this.editoffTarget.classList.add("hidden");
      this.data.set("editstate", "false");
    } 
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
