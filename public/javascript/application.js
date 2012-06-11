$(function() {
  $("ul.tabs").tabs("div.panes > div");
  $('#advanced_options').click(function(e) {
    e.preventDefault();
    $('#advanced_selections').toggle();
  });
});