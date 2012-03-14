/*global $, jQuery, window, document, escape, alert, delete, self, chrome */

$.extend({
    distinct : function(anArray) {
       var result = [];
       $.each(anArray, function(i,v){
           if ($.inArray(v, result) == -1) result.push(v);
       });
       return result;
    }
});

$(function() {

  "use strict";

  var nsp = {
    names : []
  };

  nsp.backgroundPage = chrome.extension.getBackgroundPage();

  nsp.i18n = function() {
    $("[data-namespotter-i18n]").each(function() {
      var message = chrome.i18n.getMessage($(this).attr("data-namespotter-i18n"));
      $(this).text(message);
    });
  };

  nsp.cleanup = function() {
    $('.namespotter-loader').remove();
    $('#names ul').html("");
  };

  nsp.sendRequest = function() {
    var self = this;

    chrome.tabs.getSelected(null, function(tab) {
      chrome.tabs.sendRequest(tab.id, { method : "ns_fromPopup", tabid : tab.id, taburl : tab.url, settings : nsp.backgroundPage.settings() }, function(response) {
        self.cleanup();
        if(response.status === "ok") {
          $.each(response.names, function() {
            self.names.push(this.s);
          });
          $.each($.distinct(self.names).sort(), function() {
            $('#names ul').append('<li>' + this + '</li>');
          });
        } else if (response.status === "nothing") {
          $('#content').append('<p>' + response.messages.no_names + '</p>');
        } else {
          $('#content').append('<p>' + response.messages.error + '</p>');
        }
      });
    });
  };

  nsp.init = function() {
    this.i18n();
    this.sendRequest();
  };

  nsp.init();

});