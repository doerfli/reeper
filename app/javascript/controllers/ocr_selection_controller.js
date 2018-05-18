import { Controller } from "stimulus"
import { Utils } from "../src/utils"

export default class extends Controller {
  static targets = [ "filenames", "submitbutton", "x1", "x2", "y1", "y2", "recognizedtext"]

  select(event) {
    var filename = event.target.dataset.imgid;
    console.log(filename);
    // TODO upate imgid and image
  }

  mousedown(event) {
    if (event.preventDefault) event.preventDefault();
    console.log("mousedown");
    console.log(event);
    this.data.set("ismousedown", "true");
    var x = event.pageX - event.target.offsetParent.offsetLeft - event.target.offsetLeft;
    var y = event.pageY - event.target.offsetParent.offsetTop - event.target.offsetTop;
    this.x1Target.innerHTML = _.toString(x);
    this.y1Target.innerHTML = _.toString(y);
  }

  mousemove(event) {
    if (event.preventDefault) event.preventDefault();
    if (this.data.get("ismousedown") != "true") {
      return;
    }
    console.log("mousemove");
    console.log(event);
    var x = event.pageX - event.target.offsetParent.offsetLeft - event.target.offsetLeft;
    var y = event.pageY - event.target.offsetParent.offsetTop - event.target.offsetTop;
    this.x2Target.innerHTML = _.toString(x);
    this.y2Target.innerHTML = _.toString(y);
  }

  mouseup(event) {
    if (event.preventDefault) event.preventDefault();
    console.log("mouseup");
    console.log(event);
    var x = event.pageX - event.target.offsetParent.offsetLeft - event.target.offsetLeft;
    var y = event.pageY - event.target.offsetParent.offsetTop - event.target.offsetTop;
    this.data.set("ismousedown", "false");
    this.x2Target.innerHTML = _.toString(x);
    this.y2Target.innerHTML = _.toString(y);
    // TODO show selected area on image
  }

  submit(event) {
    // TODO selection
    console.log(event);
    var url = this.data.get("url");
    var id = this.data.get("id");
    var imgid = this.data.get("imgid");
    var x1 = this.x1Target.innerHTML;
    var y1 = this.y1Target.innerHTML;
    var x2 = this.x2Target.innerHTML;
    var y2 = this.y2Target.innerHTML;
    var textArea = this.recognizedtextTarget;
    
    // TODO show spinner
    fetch(url, {
      method: 'post',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': Utils.getCsrfToken(),
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        'id': id,
        'imgid': imgid,
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2
      })
    }).then(response => {
      return response.json()
    }).then(data => {
      textArea.value = data.text
    });
  }
}