$(function() {
  $("ul.tabs").tabs("div.panes > div");
  $('#advanced_options').click(function(e) {
    e.preventDefault();
    $('#advanced_selections').toggle();
  });

  $('#all_data_sources').click(function() {
    if ($(this).is(':checked')) {
      $.each($('[id^=data_source_ids]'), function() {
        $(this).attr('checked', false).attr("disabled", true);
      });
    } else {
      $.each($('[id^=data_source_ids]'), function() {
        $(this).removeAttr("disabled");
      });
    }
  });
});