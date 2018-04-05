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
    var tagsSuggestion = this.tagsSuggestionTarget;
    tagsSuggestion.innerHTML = "";
    var terms = _.split(this.tagsTarget.value, ",");
    var term = _.last(terms);
    var term = _.trim(term);

    if ( term == "" ) {
      return;
    }

    // console.log(term);
    var url = '/tags.json?term=' + term;
    fetch(url, { credentials: 'same-origin'}).then(function json(response) {
      return response.json()
    }).then(function(data) {
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
    tags = _.map(tags, function(e) { return _.trim(e); });
    tags.push("");
    var tagsString = _.join(tags, ", ");
    this.tagsTarget.value = tagsString;
    this.tagsSuggestionTarget.innerHTML = "";
    this.tagsTarget.focus();
  }
}
