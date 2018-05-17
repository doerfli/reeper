import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "filenames", "submitbutton", "x1", "x2", "y1", "y2" ]

  select(event) {
    var filename = event.target.dataset.imgid;
    console.log(filename);
  }
}