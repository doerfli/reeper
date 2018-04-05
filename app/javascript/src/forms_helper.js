import * as $ from 'jquery/dist/jquery'

$( document ).on('turbolinks:load', function() {
  console.log("ready");
  $(".noSubmitOnEnter input").keypress(function(event) {
    // console.log(1);
    if (event.keyCode == 13 ) {
      event.preventDefault();
    }
  })
});
