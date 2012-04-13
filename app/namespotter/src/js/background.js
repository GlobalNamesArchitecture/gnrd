/*global $, jQuery, window, document, escape, alert, delete, self, chrome, localStorage */

var nsbg = nsbg || {};

(function() {

  "use strict";

  nsbg.settings = {};
  nsbg.manifest = {};

  nsbg.loadSettings = function() {
    var storage = localStorage.namespotter || "";
    this.settings = $.parseJSON(storage);
  };

  nsbg.loadManifest = function() {
    var self = this, url = chrome.extension.getURL('/manifest.json');

    $.ajax({
      type  : "GET",
      async : false,
      url   : url,
      success : function(data) {
        self.manifest = $.parseJSON(data);
      }
    });
  };

  nsbg.loadListener = function() {
    var self = this;

    chrome.browserAction.onClicked.addListener(function() {
      self.sendRequest();
      self.receiveRequests();
    });
  };

  nsbg.analytics = function(category, action, label) {
    _gaq.push(['_trackPageview'], category, action, label)
  };

  nsbg.resetBadgeIcon = function(tab) {
    chrome.browserAction.setBadgeText({ text: "", tabId : tab.id });
    chrome.browserAction.setIcon({ path : this.manifest.icons['19'], tabId : tab.id });
  };

  nsbg.setBadge = function(tab,val,color) {
    var _color = [];

    if(!color) { color = 'red'; }

    switch(color) {
      case 'red':
        _color = [255, 0, 0, 175];
      break;

      case 'green':
        _color = [0, 255, 0, 175];
      break;
    }
    chrome.browserAction.setBadgeText({ text: val, tabId : tab.id });
    chrome.browserAction.setBadgeBackgroundColor({ color : _color, tabId : tab.id});
  };

  nsbg.setIcon = function(tab, type) {
    if(!type) { return; }

    switch(type) {
      case 'default':
        chrome.browserAction.setIcon({ path : this.manifest.icons['19'], tabId : tab.id });
      break;

      case 'gray':
        chrome.browserAction.setIcon({ path : this.manifest.icons.gray, tabId : tab.id });
      break;

      case 'loader':
        chrome.browserAction.setIcon({ path : this.manifest.icons.loader, tabId : tab.id });
      break;
    }
  };

  nsbg.sendRequest = function() {
    var self = this;

    chrome.tabs.getSelected(null, function(tab) {
      self.resetBadgeIcon(tab);
      self.setIcon(tab, 'loader');
      self.analytics('initialize', 'get_url', tab.url);
      chrome.tabs.sendRequest(tab.id, { method : "ns_fromBackground", settings : self.settings, manifest : self.manifest }, function(response) {
        if(response.status && response.status === "ok") {
          if(response.scientific.length > 0) {
            self.setBadge(tab, response.scientific.length.toString(), 'green');
            self.setIcon(tab, 'default');
          } else {
            self.setBadge(tab, '0', 'red');
            self.setIcon(tab, 'gray');
          }
        } else {
          self.setIcon(tab, 'gray');
        }
        response.cleanup();
      });
    });
  };

  nsbg.receiveRequests = function() {
    chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
      sender = null;
      switch(request.method) {
        case 'ns_analytics':
          var _gaq     = _gaq || [],
              category = request.category || "",
              action   = request.action || "",
              label    = request.label || "";

          self.analytics(request.category, request.action, request.label);
        break;

        case 'ns_clipBoard':
          var names = [];
          $.each(request.names, function() {
            names.push(this.value);
          });
          $('#namespotter-clipboard').val(names.join("\n"));
          $('#namespotter-clipboard')[0].select();
          document.execCommand("copy", false, null);
        break;

        default:
          sendResponse({});
      }
    });
  };

  nsbg.init = function() {
    this.loadSettings();
    this.loadManifest();
    this.loadListener();
  };

  nsbg.init();

}());