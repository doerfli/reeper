import { Controller } from "@hotwired/stimulus"
import { Utils } from "../src/utils"

export default class extends Controller {
  static targets = ["deleteButtons", 
    "imagelg", "imagebox", "imagefulllink",
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

  imageLgShow(event) {
    const imageurl = event.currentTarget.dataset.imagelgurl;
    const imagefullurl = event.currentTarget.dataset.imagefullurl;
    console.log(imageurl);
    this.imagelgTarget.src = imageurl;
    this.imagefulllinkTarget.href = imagefullurl;
    this.imageboxTarget.classList.toggle("hidden");
  }

  imageLgClose(event) {
    this.imageboxTarget.classList.add("hidden");
  }

}
