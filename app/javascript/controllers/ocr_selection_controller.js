import { Controller } from "stimulus"
import { Utils } from "../src/utils"
import * as clipboard from "clipboard-polyfill"

export default class extends Controller {
  static targets = [ "filenames", "submitbutton", "x1", "x2", "y1", "y2", "recognizedtext", "canvas", "toclipboardbtn", "spinner", "language"]

  initialize() {
    // initialize canvas size
    let canvas = this.canvasTarget;
    canvas.width = canvas.clientWidth;
    canvas.height = canvas.clientHeight;
  
    this.drawImageToCanvas(this.data.get("imgurl"));
  }

  drawImageToCanvas(url, drawMore) {
    var thisdata = this.data;
    var canvas = this.canvasTarget;
    var context = canvas.getContext('2d');
    
    var drawing = new Image();
    drawing.src = url;
    drawing.onload = function() {
      // get canvas width
      var width = canvas.clientWidth;
      // calculate height relative to canvas width
      var ratio = width / drawing.width;
      var height = ratio * drawing.height;

      if ( height > canvas.clientHeight) {
        // if height > canvas height -> resize height to canvas height and width relative to height
        height = canvas.clientHeight;
        ratio = height / drawing.height;
        width = ratio * drawing.width;
      }

      thisdata.set("ratio", ratio);
      context.drawImage(drawing,0,0, width, height);
      if ( drawMore != null ) {
        drawMore();
      }
    };
  }

  select(event) {
    var id = event.target.dataset.imgid;
    var url = event.target.dataset.imgurl;
    this.data.set("imgid", id);
    this.data.set("imgurl", url);
    this.initialize(url);
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
    if (event.movementX == 0 && event.movementY == 0) { // no movement
      return;
    }
    console.log("mousemove");
    console.log(event);
    var ratio = _.toNumber(this.data.get("ratio"));
    var x = event.pageX - event.target.offsetParent.offsetLeft - event.target.offsetLeft;
    var y = event.pageY - event.target.offsetParent.offsetTop - event.target.offsetTop;
    this.x2Target.innerHTML = _.toString(x);
    this.y2Target.innerHTML = _.toString(y);

    let canvas = this.canvasTarget;
    let context = canvas.getContext('2d');
    let x1 = _.toNumber(this.x1Target.innerHTML);
    let y1 = _.toNumber(this.y1Target.innerHTML);
    let w = x - x1;
    let h = y - y1;
    
    this.drawImageToCanvas(this.data.get("imgurl"));
    context.fillStyle = "blue";
    context.globalAlpha = 0.3;
    context.fillRect(x1, y1, w, h);
    context.globalAlpha = 1.0;
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
    
    let canvas = this.canvasTarget;
    let context = canvas.getContext('2d');
    let x1 = _.toNumber(this.x1Target.innerHTML);
    let y1 = _.toNumber(this.y1Target.innerHTML);
    
    context.fillStyle = "blue";
    context.globalAlpha = 0.3;
    context.fillRect(x1, y1, x - x1, y - y1);
    context.globalAlpha = 1.0;
  }

  submit(event) {
    console.log(event);
    var url = this.data.get("ocrurl");
    var id = this.data.get("id");
    var imgid = this.data.get("imgid");
    var ratio = _.toNumber(this.data.get("ratio"));
    var x1 = _.toNumber(this.x1Target.innerHTML) / ratio;
    var y1 = _.toNumber(this.y1Target.innerHTML) / ratio;
    var x2 = _.toNumber(this.x2Target.innerHTML) / ratio;
    var y2 = _.toNumber(this.y2Target.innerHTML) / ratio;
    var textArea = this.recognizedtextTarget;
    var language = this.languageTarget.value;
    
    this.spinnerTarget.classList.remove("display_none");
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
        'y2': y2,
        'language': language
      })
    }).then(response => {
      this.spinnerTarget.classList.add("display_none");
      return response.json()
    }).then(data => {
      textArea.value = data.text
    });

    this.toclipboardbtnTarget.classList.add("is-primary");
    this.toclipboardbtnTarget.classList.remove("is-success");
  }

  toclipboard() {
    clipboard.writeText(this.recognizedtextTarget.value);
    this.toclipboardbtnTarget.classList.remove("is-primary");
    this.toclipboardbtnTarget.classList.add("is-success");
  }
}