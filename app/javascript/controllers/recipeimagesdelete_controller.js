import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "filenames", "submitbutton" ]

  select(event) {
    var filename = event.target.dataset.filename;
    console.log(filename);
    var filenames_list = _.split(this.filenamesTarget.value, ",");
    filenames_list = _.without(filenames_list, ""); // remove empty value
    console.log(filenames_list);
    if (_.indexOf(filenames_list, filename) > -1 ) { // name exists
      filenames_list = _.without(filenames_list, filename);
      event.target.classList.remove("selected_for_delete");
    } else { // name does not exist
      filenames_list.push(filename);
      event.target.classList.add("selected_for_delete");
    }
    this.filenamesTarget.value = _.join(filenames_list, ",");
    this.submitbuttonTarget.disabled = filenames_list.length == 0;
  }
}
