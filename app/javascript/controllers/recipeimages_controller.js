import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "appendimgtmpl", "images" ]

  // initialize() {
  //   console.log("initialize");
  // }

  add() {
    // console.log(this.appendimgtmplTarget);
    var nodeToInsert = this.appendimgtmplTarget.cloneNode(true);
    nodeToInsert.style.display = 'block';
    nodeToInsert.querySelector("input").removeAttribute('disabled');
    nodeToInsert.removeAttribute("data-target");
    // console.log(nodeToInsert);
    this.imagesTarget.append(nodeToInsert);
  }
}
