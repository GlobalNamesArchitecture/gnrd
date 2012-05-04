/*global $, jQuery, window, document, escape, alert, delete, self, chrome, localStorage, Image */

var nsbg = nsbg || {},
    _gaq = _gaq || [];

$(function() {

  "use strict";

  nsbg.settings = {};
  nsbg.manifest = {};
  nsbg.total    = {};

  nsbg.animateIcon = function(tab) {
    var self    = this,
        img     = new Image(),
        c       = $('#canvas')[0].getContext('2d'),
        counter = 0;

    self.total[tab.id] = -1;

    window.setTimeout(function animate() {
      if(self.total[tab.id] === 0) {
        self.setIcon(tab, 'gray');
      } else if (self.total[tab.id] > 0) {
        self.setIcon(tab, 'default');
      } else {
        img.src = self.manifest.icons['19' + (counter % 4).toString()];
        img.onload = function() {
          c.clearRect(0, 0, 19, 15);
          c.drawImage(img, 0, 0, 19, 15);
          chrome.browserAction.setIcon({ imageData : c.getImageData(0, 0, 19, 15), tabId : tab.id });
        };
        counter += 1;
        window.setTimeout(animate, 125);
      }
    }, 125);
  };

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

  nsbg.loadAnalytics = function() { 
   var ga = document.createElement('script'),
       s  = document.getElementsByTagName('script')[0];

   _gaq.push(['_setAccount', this.manifest.namespotter.ga]);
   _gaq.push(['_trackPageview']);
   ga.type = 'text/javascript';
   ga.async = true;
   ga.src = 'https://ssl.google-analytics.com/ga.js';
   s.parentNode.insertBefore(ga, s);
  };

  nsbg.analytics = function(category, action, label) {
    _gaq.push(['_trackPageview'], category, action, label);
  };

  nsbg.resetBadgeIcon = function(tab) {
    chrome.browserAction.setBadgeText({ text: "", tabId : tab.id });
    this.setIcon(tab, 'default');
    chrome.browserAction.setTitle({ title : chrome.i18n.getMessage("manifest_title") , tabId : tab.id });
  };

  nsbg.setBadge = function(tab, val, color) {
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
    chrome.browserAction.setBadgeText({ text: val, tabId : tab.id });
    chrome.browserAction.setBadgeBackgroundColor({ color : color, tabId : tab.id });

    if(val === '0') { title = chrome.i18n.getMessage("toolbox_no_names"); }
    chrome.browserAction.setTitle({ title : title, tabId : tab.id });
  };

  nsbg.setIcon = function(tab, type) {
    if(!type) { return; }

    var img = new Image(),
        c   = $('#canvas')[0].getContext('2d');

    switch(type) {
      case 'default':
        img.src = this.manifest.icons['19'];
        img.onload = function() {
          c.clearRect(0, 0, 19, 15);
          c.drawImage(img, 0, 0, 19, 15);
          chrome.browserAction.setIcon({ imageData : c.getImageData(0, 0, 19, 15), tabId : tab.id });
        };
      break;

      case 'gray':
        img.src = this.manifest.icons.gray;
        img.onload = function() {
          c.clearRect(0, 0, 19, 15);
          c.drawImage(img, 0, 0, 19, 15);
          chrome.browserAction.setIcon({ imageData : c.getImageData(0, 0, 19, 15), tabId : tab.id });
        };
      break;
    }
  };

  nsbg.sendRequest = function() {
    var self = this, data = {};

    chrome.tabs.getSelected(null, function(tab) {
      self.analytics('initialize', 'get_url', tab.url);
      self.resetBadgeIcon(tab);
      self.animateIcon(tab);
      data = { url : tab.url, settings : self.settings, tab : tab };
      chrome.tabs.sendRequest(tab.id, { method : "ns_initialize", params : data });
    });
  };

  nsbg.receiveRequests = function() {
    var self = this, names = [];

    chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
      sender = null;

      switch(request.method) {
        case 'ns_content':
          sendResponse({"message" : "success"});
          self.resetBadgeIcon(request.params.tab);
          $.ajax({
            type     : "POST",
            data     : request.params.data,
            dataType : 'json',
            url      : self.manifest.namespotter.ws,
            success  : function(response) {
              if(response.total > 0) {
                chrome.tabs.sendRequest(request.params.tab.id, { method : "ns_highlight", params : response });
              } else {
                self.total[request.params.tab.id] = 0;
                self.setBadge(request.params.tab, '0', 'red');
              }
            },
            error : function() {
              self.total[request.params.tab.id] = 0;
              self.setBadge(request.params.tab, chrome.i18n.getMessage('failed'), 'red');
            }
          });
        break;

        case 'ns_complete':
          var total = "";

          if(!request.params.total) {
            self.total[request.params.tab.id] = 0;
            self.setBadge(request.params.tab, total, 'red');
          } else {
            total = (request.params.total > 9999) ? ">999" : request.params.total.toString();
            self.total[request.params.tab.id] = request.params.total;
            self.setBadge(request.params.tab, total, 'green');
          }
        break;

        case 'ns_analytics':
          var category = request.params.category || "",
              action   = request.params.action || "",
              label    = request.params.label || "";

          self.analytics(category, action, label);
          sendResponse({"message" : "success"});
        break;

        case 'ns_clipBoard':
          if(request.params.names.length > 0) {
            $.each(request.params.names, function() {
              names.push(this.value);
            });
            $('#namespotter-clipboard').val(names.join("\n"));
            $('#namespotter-clipboard')[0].select();
            document.execCommand("copy", false, null);
            sendResponse({"message" : "success"});
          } else {
            sendResponse({"message" : "failed"});
          }
        break;

        case 'ns_closed':
          self.resetBadgeIcon(request.tab);
          sendResponse({"message" : "success"});
        break;

        case 'ns_saveSettings':
          localStorage.removeItem("namespotter");
          localStorage.namespotter = JSON.stringify(request.params);
          self.loadSettings();
          self.sendRequest();
          sendResponse({"message" : "success"});
        break;

        default:
          sendResponse({});
      }
    });
  };

  nsbg.cleanup = function() {
    this.settings = {};
    this.manifest = {};
  };

  nsbg.init = function() {
    var self = this;

    chrome.browserAction.onClicked.addListener(function() {
      self.cleanup();
      self.loadManifest();
      self.loadAnalytics();
      self.loadSettings();
      self.sendRequest();
    });

    self.receiveRequests();
  };

  nsbg.init();

});