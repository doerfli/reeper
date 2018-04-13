import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "tags", "tagsSuggestion" ]

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
    var url = _.replace(this.data.get("url"), "term", encodeURI(term));
    fetch(url, { credentials: 'same-origin'}).then(function json(response) {
      return response.json()
    }).then(function(data) {
      // console.log(data);
      data.forEach(function(element) {
        var tagElement = document.createElement("span");
        tagElement.classList += "tag is-dark";
        tagElement.setAttribute("data-action", "click->recipeform#addtag");
        tagElement.appendChild(document.createTextNode(element));
        tagsSuggestion.appendChild(tagElement);
      });
    });
  }

  addtag(element) {
    // console.log(element);
    var tag = element.target.innerText;
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
