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

  var nso = {};

  nso.i18n = function() {
    $("[data-namespotter-i18n]").each(function() {
      var message = chrome.i18n.getMessage($(this).attr("data-namespotter-i18n"));
      $(this).text(message);
    });
  };

  nso.save = function() {
    localStorage["namespotter"] = JSON.stringify($('form').serializeJSON());
    $('#status').text(chrome.i18n.getMessage("options_saved_message")).show();
    setTimeout(function() {
      $('#status').hide();
    }, 1000);
  };

  nso.restore = function() {
    var data = localStorage["namespotter"];
    if(!data) { return; }

    $.each($.parseJSON(data), function(name, value) {
      $('input:radio[name="' + name + '"][value="' + value + '"]').attr('checked', true);
      $('input[name="' + name + '"]').val(value);
    });
  };

  nso.init = function() {
    var self = this;

    self.i18n();
    self.restore();
    $('#submit').click(function(e) {
      e.preventDefault();
      self.save();
    });
  };

  nso.init();

});