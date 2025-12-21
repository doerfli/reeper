import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "tags", "tagsSuggestion", "rating", "rating-1", "rating-2", "rating-3", "rating-4", "rating-5" ]

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
        var tagElement = document.createElement("div");
        tagElement.classList += "tag";
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

  addSuggestedTag(event) {
    var button = event.currentTarget;
    var newTag = button.getAttribute('data-tag-value');
    
    // Get current tags and check for duplicates
    var currentValue = this.tagsTarget.value;
    var tags = _.split(currentValue, ",");
    tags = _.map(tags, function(e) { return _.trim(e); });
    tags = _.filter(tags, function(e) { return e !== ""; });
    
    // Check if tag already exists (case-insensitive)
    var tagExists = _.some(tags, function(existingTag) {
      return existingTag.toLowerCase() === newTag.toLowerCase();
    });
    
    // Only add if it doesn't exist
    if (!tagExists) {
      tags.push(newTag);
      tags.push(""); // Add empty string for trailing comma
      var tagsString = _.join(tags, ", ");
      this.tagsTarget.value = tagsString;
      
      // Visual feedback: disable the button
      button.disabled = true;
      button.classList.remove('hover:bg-blue-200', 'cursor-pointer');
      button.classList.add('opacity-50', 'cursor-not-allowed', 'bg-gray-200', 'text-gray-500');
    }
  }

  setrating(event) {
    var rating = this.ratingTarget;
    var value = parseInt(event.params.rating);
    rating.setAttribute("value", value);
    // toggle classes
    for (var i = 1; i <= 5; i++) {
      var rating = this["rating-" + i + "Target"];
      // console.log(rating);
      if (i <= value) {
        rating.classList.remove("far", "fas");
        rating.classList.add("fas");
      } else {
        rating.classList.remove("far", "fas");
        rating.classList.add("far");
      }
    }
  }
}
