import { Controller } from "@hotwired/stimulus"
import { Utils } from "../src/utils"

export default class extends Controller {
  static targets = ["deleteButtons", 
    "favoriteicon",
  ];

  delete() {
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
      location.href = data.redirect_url;
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
    });
    // toggle heart icon
    var favoriteIcon = this.favoriteiconTarget;
    favoriteIcon.classList.toggle("far");
    favoriteIcon.classList.toggle("fas");
  }

}
