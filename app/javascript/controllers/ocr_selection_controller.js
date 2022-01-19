import { Controller } from "@hotwired/stimulus"
import { Utils } from "../src/utils"
import * as clipboard from "clipboard-polyfill"

export default class extends Controller {
  static targets = [ "filenames", 
                     "canvasImg", "canvasSelect",
                     "submitbutton", "toclipboardbtn", "spinner", "language",
                     "recognizedtext"]

  initialize() {
    // initialize canvas size
    let canvas = this.canvasImgTarget;
    canvas.width = canvas.clientWidth;
    canvas.height = canvas.clientHeight;

    let canvasS = this.canvasSelectTarget;
    canvasS.width = canvasS.clientWidth;
    canvasS.height = canvas.clientHeight;
  
    this.drawImageToCanvas(this.data.get("imgurl"));
  }

  drawImageToCanvas(url) {
    var thisdata = this.data;
    var canvasImg = this.canvasImgTarget;
    var contextImg = canvasImg.getContext('2d');
    
    var drawing = new Image();
    drawing.src = url;
    drawing.onload = function() {
      // get canvas width
      var width = canvasImg.clientWidth;
      // calculate height relative to canvas width
      var ratio = width / drawing.width;
      var height = ratio * drawing.height;

      if ( height > canvasImg.clientHeight) {
        // if height > canvas height -> resize height to canvas height and width relative to height
        height = canvasImg.clientHeight;
        ratio = height / drawing.height;
        width = ratio * drawing.width;
      }

      thisdata.set("ratio", ratio);
      contextImg.drawImage(drawing,0,0, width, height);
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
    // console.log("mousedown");
    // console.log(event);
    this.data.set("ismousedown", "true");
    var x = event.offsetX;
    var y = event.offsetY;
    this.data.set("x1", x);
    this.data.set("y1", y);
  }

  mousemove(event) {
    if (event.preventDefault) event.preventDefault();
    if (this.data.get("ismousedown") != "true") {
      return;
    }
    if (event.movementX == 0 && event.movementY == 0) { // no movement
      return;
    }
    // console.log("mousemove");
    // console.log(event);
    this.calculateAndDrawBoundingBox(event);
  }

  mouseup(event) {
    if (event.preventDefault) event.preventDefault();
    // console.log("mouseup");
    // console.log(event);
    this.data.set("ismousedown", "false");
    this.calculateAndDrawBoundingBox(event);
  }

  calculateAndDrawBoundingBox(event) {
    var x = event.offsetX;
    var y = event.offsetY;

    this.data.set("x2", x);
    this.data.set("y2", y);
    
    let x1 = this.data.get("x1");
    let y1 = this.data.get("y1");
  
    this.redrawBoundingBox(x1, y1, x - x1, y - y1);
  }

  redrawBoundingBox(x, y, w, h) {
    var canvasSelect = this.canvasSelectTarget;
    var contextSelect = canvasSelect.getContext('2d');
    contextSelect.clearRect(0,0,canvasSelect.clientWidth, canvasSelect.clientHeight);
    contextSelect.fillStyle = "blue";
    contextSelect.globalAlpha = 0.3;
    contextSelect.fillRect(x, y, w, h);
    contextSelect.globalAlpha = 1.0;
  }

  submit(event) {
    console.log(event);
    var url = this.data.get("ocrurl");
    var id = this.data.get("id");
    var imgid = this.data.get("imgid");
    var ratio = _.toNumber(this.data.get("ratio"));
    var x1 = this.data.get("x1") / ratio;
    var y1 = this.data.get("y1") / ratio;
    var x2 = this.data.get("x2") / ratio;
    var y2 = this.data.get("y2") / ratio;
    var textArea = this.recognizedtextTarget;
    var language = this.languageTarget.value;
    
    this.spinnerTarget.classList.remove("hidden");
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
      this.spinnerTarget.classList.add("hidden");
      return response.json()
    }).then(data => {
      textArea.value = data.text
    });

    // this.toclipboardbtnTarget.classList.add("is-primary");
    this.toclipboardbtnTarget.classList.remove("button-success");
  }

  toclipboard() {
    clipboard.writeText(this.recognizedtextTarget.value);
    // this.toclipboardbtnTarget.classList.remove("is-primary");
    this.toclipboardbtnTarget.classList.add("button-success");
  }
}