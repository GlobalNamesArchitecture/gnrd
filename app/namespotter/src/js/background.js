/*global $, jQuery, window, document, escape, alert, delete, self, chrome, localStorage */

var nsbg = nsbg || {};

(function() {

  "use strict";

  nsbg.settings = {};
  nsbg.manifest = {};
  nsbg.tab      = {};
  nsbg.timeout  = 5000;

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
      self.loadSettings();
      self.sendRequest();
      self.receiveRequests();
    });
  };

  nsbg.analytics = function(category, action, label) {
    _gaq.push(['_trackPageview'], category, action, label);
  };

  nsbg.resetBadgeIcon = function() {
    chrome.browserAction.setBadgeText({ text: "", tabId : this.tab.id });
    chrome.browserAction.setIcon({ path : this.manifest.icons['19'], tabId : this.tab.id });
    chrome.browserAction.setTitle({ title : chrome.i18n.getMessage("manifest_title") , tabId : this.tab.id });
  };

  nsbg.setBadge = function(val, color) {
    var title = '';

    if(!color) { color = 'red'; }

    switch(color) {
      case 'red':
        color = [255, 0, 0, 175];
      break;

      case 'green':
        color = [0, 255, 0, 175];
      break;

      default:
        color = [255, 0, 0, 175];
    }
    chrome.browserAction.setBadgeText({ text: val, tabId : this.tab.id });
    chrome.browserAction.setBadgeBackgroundColor({ color : color, tabId : this.tab.id });

    if(val === '0') { title = chrome.i18n.getMessage("toolbox_no_names"); }
    chrome.browserAction.setTitle({ title : title, tabId : this.tab.id });
  };

  nsbg.setIcon = function(type) {
    if(!type) { return; }

    switch(type) {
      case 'default':
        chrome.browserAction.setIcon({ path : this.manifest.icons['19'], tabId : this.tab.id });
      break;

      case 'gray':
        chrome.browserAction.setIcon({ path : this.manifest.icons.gray, tabId : this.tab.id });
      break;

      case 'loader':
        chrome.browserAction.setIcon({ path : this.manifest.icons.loader, tabId : this.tab.id });
      break;
    }
  };

  nsbg.sendRequest = function() {
    var self = this, data = {};

    chrome.tabs.getSelected(null, function(tab) {
      self.tab = tab;
      self.resetBadgeIcon();
      self.setIcon('loader');
      self.analytics('initialize', 'get_url', tab.url);
      data = { url : tab.url, settings : self.settings };
      chrome.tabs.sendRequest(tab.id, { method : "ns_initialize", params : data });
    });
  };

  nsbg.receiveRequests = function() {
    var self = this, names = [];

    chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
      sender = null;
      switch(request.method) {
        case 'ns_content':
          $.ajax({
            type     : "POST",
            async    : false,
            data     : request.params,
            dataType : 'json',
            url      : self.manifest.namespotter.ws,
            timeout  : self.timeout,
            success  : function(response) {
              if(response.total > 0) {
                self.setBadge(response.total.toString(), 'green');
                self.setIcon('default');
              } else {
                self.setBadge('0', 'red');
                self.setIcon('gray');
              }
              sendResponse(response);
            },
            error : function() {
              sendResponse({"status" : "FAILED"});
              self.setBadge(chrome.i18n.getMessage('failed'), 'red');
              self.setIcon('gray');
            }
          });
        break;

        case 'ns_analytics':
          var _gaq     = _gaq || [],
              category = request.params.category || "",
              action   = request.params.action || "",
              label    = request.params.label || "";

          self.analytics(category, action, label);
        break;

        case 'ns_clipBoard':
          $.each(request.params.names, function() {
            names.push(this.value);
          });
          $('#namespotter-clipboard').val(names.join("\n"));
          $('#namespotter-clipboard')[0].select();
          document.execCommand("copy", false, null);
          sendResponse({"message" : "success"});
        break;

        case 'ns_closed':
          self.resetBadgeIcon();
        break;

        case 'ns_saveSettings':
          localStorage.removeItem("namespotter");
          localStorage.namespotter = JSON.stringify(request.params);
          sendResponse({"message" : "success"});
          self.loadSettings();
          self.sendRequest();
        break;

        default:
          sendResponse({});
      }
    });
  };

  nsbg.init = function() {
    this.loadManifest();
    this.loadListener();
  };

  nsbg.init();

}());