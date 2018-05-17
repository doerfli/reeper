import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "filenames", "submitbutton", "x1", "x2", "y1", "y2" ]

  select(event) {
    var filename = event.target.dataset.imgid;
    console.log(filename);
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
  }
}