var forms = document.getElementsByClassName("noSubmitOnEnter");
for (let form of forms) {
  let inputs = form.getElementsByTagName("input");
  for (let input of inputs) {
    input.addEventListener("keypress", function(event) {
      if (event.key === "Enter") {
        event.preventDefault();
      }
    });  
  }
}
