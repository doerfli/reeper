import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "appendimgtmpl", "images", "tags", "tagsSuggestion" ]

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

  findtags() {
    var terms = _.split(this.tagsTarget.value, ",");
    var term = _.last(terms);
    var term = _.trim(term);
    // console.log(term);
    var tagsSuggestion = this.tagsSuggestionTarget;
    fetch('/tags.json?term=' + term).then(function json(response) {
      return response.json()
    }).then(function(data) {
      tagsSuggestion.innerHTML = "";
      // console.log(data);
      data.forEach(function(element) {
        var tagElement = document.createElement("span");
        tagElement.classList += "tag";
        tagElement.setAttribute("data-action", "click->recipeform#addtag");
        tagElement.appendChild(document.createTextNode(element));
        tagsSuggestion.appendChild(tagElement);
      });
    });
  }

  addtag(element) {
    var tag = element.srcElement.innerText;
    var tags = _.split(this.tagsTarget.value, ",");
    var tags = _.dropRight(tags);
    tags.push(tag);
    tags.push("");
    var tagsString = _.join(tags, ", ");
    this.tagsTarget.value = tagsString;
    this.tagsSuggestionTarget.innerHTML = "";
  }
}
