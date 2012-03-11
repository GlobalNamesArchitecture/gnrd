$(function() {

  var bg =  chrome.extension.getBackgroundPage();

  $("[data-namespotter-i18n]").each(function() {
    var message = chrome.i18n.getMessage($(this).attr("data-namespotter-i18n"));
    $(this).text(message);
  });

  chrome.tabs.getSelected(null, function(tab) {
    chrome.tabs.sendRequest(tab.id, { method : "NS_fromPopup", tabid : tab.id, taburl : tab.url }, function(response) {
      $('.namespotter-loader').remove();
      if(response.status === "ok") {
        $.each(response.names.scientific, function() {
          $('#names ul').append('<li>' + this + '</li>');
        });
      } else if (response.status === "nothing") {
        $('#content').append('<p>' + response.messages.no_names + '</p>');
      } else {
        $('#content').append('<p>' + response.messages.error + '</p>');
      }
    });
  });

});