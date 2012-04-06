/*global $, jQuery, window, document, escape, alert, delete, self, chrome */

$.extend({
  distinct : function(anArray) {

    "use strict";

    var result = [];
    $.each(anArray, function() {
      if ($.inArray(this, result) === -1) { result.push(this); }
    });
    return result;
  }
});

$(function() {

  "use strict";

  var nsp = {
    names : [],
    url : ""
  };

  nsp.i18n = function() {
    $("[data-namespotter-i18n]").each(function() {
      var message = chrome.i18n.getMessage($(this).attr("data-namespotter-i18n"));
      $(this).text(message);
    });
  };

  nsp.cleanup = function() {
    $('.namespotter-loader').remove();
    $('#hook a').removeClass("success").removeClass("error");
    $('#names ul').html("");
    this.names = [];
    this.url = "";
  };

  nsp.sendRequest = function() {
    var self = this, background = chrome.extension.getBackgroundPage();

    chrome.tabs.getSelected(null, function(tab) {
      chrome.tabs.sendRequest(tab.id, { method : "ns_fromPopup", tabid : tab.id, taburl : tab.url, settings : $.parseJSON(background.settings()), manifest : background.chrome.manifest }, function(response) {
        self.cleanup();
        self.url = tab.url;
        if(response.status === "ok") {
          $.each(response.names, function() {
            self.names.push(this.scientificName.replace(/[\[\]]/gi,""));
          });
          $.each($.distinct(self.names.sort()), function() {
            $('#names ul').append('<li>' + this + '</li>');
          });
          if(settings !== null && settings.hook !== undefined && settings.hook !== "") {
            $('#hook').show().find("a").click(function(e) {
              e.preventDefault();
              self.webHook(settings);
            });
          }
        } else if (response.status === "nothing") {
          $('#content').append('<p>' + response.messages.no_names + '</p>');
        } else {
          $('#content').append('<p>' + response.messages.error + '</p>');
        }
      });
    });
  };

  nsp.webHook = function(settings) {
    var self = this;

    $.ajax({
      type : "POST",
      data : { url : self.url, names : $.distinct(self.names) },
      url  : settings.hook,
      success : function(data) {
        data = null;
        $('#hook a').addClass("success");
      },
      error : function() {
        $('#hook a').addClass("error");
      }
    });
  };

  nsp.init = function() {
    $('#settings a').click(function(e) {
      e.preventDefault();
      chrome.tabs.create({
        url: "options.html"
      });
    });
    this.i18n();
    this.sendRequest();
  };

  nsp.init();

});