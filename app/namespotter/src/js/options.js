// Saves options to localStorage.
(function( $ ){
  $.fn.serializeJSON = function() {
    var json = {};

    jQuery.map($(this).serializeArray(), function(n, i){
      json[n['name']] = n['value'];
    });
    return json;
  };
})( jQuery );

$(function() {

  var NameSpotterOptions = {};

  NameSpotterOptions.save = function() {
    localStorage["namespotter"] = JSON.stringify($('form').serializeJSON());
    $('#status').text(chrome.i18n.getMessage("saved")).show();
    setTimeout(function() {
      $('#status').hide();
    }, 750);
  };

  NameSpotterOptions.restore = function() {
    var data = localStorage["namespotter"];
    if(!data) { return; }

    $.each($.parseJSON(data), function(name, value) {
      $('input:radio[name="' + name + '"][value="' + value + '"]').attr('checked', true);
    });
  };

  NameSpotterOptions.init = function() {
    var self = this;

    self.restore();
    $('#submit').click(function(e) {
      e.preventDefault();
      self.save();
    });
  };

  NameSpotterOptions.init();

});