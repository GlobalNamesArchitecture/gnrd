/*global $, jQuery, window, document, escape, alert, delete, self, chrome, localStorage */

(function($){
  "use strict";

  $.fn.serializeJSON = function() {
    var json = {};

    $.map($(this).serializeArray(), function(n, i){
      i = null;
      json[n.name] = n.value;
    });
    return json;
  };
}(jQuery));

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

  var ns = {
    status      : "",
    timeout     : 5000,
    tab         : {},
    names       : [],
    keys        : {},
    scientific  : [],
    manifest    : {},
    settings    : {},
    scrub       : ['select', 'input', 'textearea', 'script', 'style', 'noscript', 'img']
  };

  ns.compareStringLengths = function(a, b) {
    if (a.length < b.length) { return 1;  }
    if (a.length > b.length) { return -1; }
    return 0;
  };

  ns.verbatim = function() {
    var verbatim = [], self = this;

    $.each(this.names, function() {
      verbatim.push(this.verbatim);
      self.keys[this.verbatim.toLowerCase()] = [];
      self.keys[this.verbatim.toLowerCase()].push(encodeURIComponent(this.scientificName.replace(/[\[\]]/gi,"")));
    });
    return verbatim.sort(this.compareStringLengths);
  };

  ns.highlight = function() {
    var self = this;

    $('body').highlight(this.verbatim(), { className : 'namespotter-highlight', wordsOnly : true });
    $.each($('.namespotter-highlight'), function() {
      $(this).attr("data-highlight", self.keys[$(this).text().toLowerCase()]);
    });
  };

  ns.unhighlight = function() {
    $('body').unhighlight({className: 'namespotter-highlight'});
  };

  ns.i18n = function() {
    $.each($("[data-namespotter-i18n]"), function() {
      var message = chrome.i18n.getMessage($(this).attr("data-namespotter-i18n"));
      $(this).html(message);
    });
  };

  ns.activateToolBox = function() {
    var self = this,
        maxZ = Math.max.apply(null, $.map($('body *'), function(e,n) {
          n = null;
          if($(e).css('position') === 'absolute') {
            return parseInt($(e).css('z-index')) || 100000;
          }
        }));

    $('#namespotter-toolbox').css('z-index', maxZ+1);
    $('#namespotter-names').resizer();

    $('.namespotter-close').click(function(e) {
      e.preventDefault();
      $('#namespotter-toolbox').remove();
      self.unhighlight();
      chrome.extension.sendRequest({ method : "ns_closed", params : { tab : self.tab } });
    });
    $('.namespotter-minimize').click(function(e) {
      e.preventDefault();
      $('#namespotter-names').height('36px');
      $('#namespotter-names-list').height('0px');
    });
    $('.namespotter-maximize').click(function(e) {
      e.preventDefault();
      $('#namespotter-names').height('400px');
      $('#namespotter-names-list').height('436px');
    });

    if(!self.settings || !self.settings.engine) {
      $('input:radio[name="engine"][value=""]').attr('checked', true);
    }

    if(self.settings) {
      $.each(self.settings, function(name, value) {
        var ele = $('form :input[name="' + name + '"]');
        $.each(ele, function() {
          if(this.type === 'checkbox' || this.type === 'radio') {
            this.checked = (this.value === value);
          } else {
            this.value = value;
          }
        });
      });
    }
  };

  ns.makeToolBox = function() {
    var toolbox = '';

    $.ajax({
      type     : "GET",
      async    : false,
      url      : chrome.extension.getURL("/toolbox.html"),
      dataType : 'html',
      success  : function(response) {
        toolbox = response;
      }
    });
    $('body').append(toolbox);
    this.activateToolBox();
  };

  ns.showSettings = function() {
    $('#namespotter-names-buttons').hide();
    $('#namespotter-names-list').hide();
    $('#namespotter-settings').show();
  };

  ns.hideSettings = function() {
    $('#namespotter-settings').hide();
    $('#namespotter-names-buttons').show();
    $('#namespotter-names-list').show();
  };

  ns.saveSettings = function() {
    var data = $('#namespotter-settings-form').serializeJSON();

    this.clearvars();
    $('#namespotter-names').fadeTo('slow', 0.3, function() {
      chrome.extension.sendRequest({ method : "ns_saveSettings", params : data });
    });
  };

  ns.addNames = function() {
    var self = this, scientific = [];

    $.each(self.names, function() {
      scientific.push(this.scientificName.replace(/[\[\]]/gi,""));
    });
    self.scientific = $.distinct(scientific.sort());
    $.each(self.scientific, function() {
      var encoded = encodeURIComponent(this);
      $('#namespotter-names-list ul').append('<li><input type="checkbox" id="ns-' + encoded + '" name="names[' + encoded + ']" value="' + this + '"><label for="ns-' + encoded + '">' + this + '</label></li>');
    });
  };

  ns.activateButtons = function() {
    var self = this, data = {};

    $('.namespotter-select-all').click(function(e) {
      e.preventDefault();
      $.each($('input', '#namespotter-names-list'), function() {
        $(this).attr("checked", true);
      });
    });
    $('.namespotter-select-none').click(function(e) {
      e.preventDefault();
      $.each($('input', '#namespotter-names-list'), function() {
        $(this).attr("checked", false);
      });
    });
    $('.namespotter-select-copy').click(function(e) {
      e.preventDefault();
      data = { names: $('#namespotter-names-form').serializeArray() };
      chrome.extension.sendRequest({ method : "ns_clipBoard", params : data });
    });
    $('.namespotter-settings').click(function(e) {
      e.preventDefault();
      self.showSettings();
    });
    $('.namespotter-settings-save').click(function(e) {
      e.preventDefault();
      self.saveSettings();
      self.hideSettings();
    });
    $('.namespotter-settings-cancel').click(function(e) {
      e.preventDefault();
      self.hideSettings();
    });
  };

  ns.analytics = function(category, action, label) {
    var data = { category : category, action : action, label : label };

    chrome.extension.sendRequest({ method : "ns_analytics", params : data });
  };

  ns.getParameterByName = function(name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(window.location.search);
    if(results == null) {
      return "";
    } else {
      return decodeURIComponent(results[1].replace(/\+/g, " "));
    }
  };

  ns.sendPage = function() {
    var self   = this,
        engine = (self.settings && self.settings.engine) ? self.settings.engine : null,
        data   = { unique : true },
        url    = self.tab.url,
        ext    = url.split('.').pop().toLowerCase(),
        body   = "";

    if(url.indexOf("docs.google.com") != -1 && ext === "pdf") {
      data.url = self.getParameterByName('url');
    } else if(ext === "pdf") {
      data.url = url;
    } else {
      body = $('body').clone();
      $.each(self.scrub, function() {
        body.find(this).remove();
      });
      data.input = body.text().replace(/\s+/g, " ");
    }
    
    if(engine) {
      data.engine = engine;
    }

    $.ajax({
      type     : "POST",
      async    : false,
      data     : data,
      dataType : 'json',
      url      : self.manifest.namespotter.ws,
      timeout  : self.timeout,
      success  : function(response) {
        self.status = "ok";
        self.names = response.names;
      },
      error : function() {
        self.status = "failed";
      }
    });
  };

  ns.clearvars = function() {
    this.status = "";
    this.tab = {};
    this.names = [];
    this.keys = {};
    this.scientific = [];
    this.manifest = {};
    this.settings = {};
  };

  ns.cleanup = function() {
    $('#namespotter-toolbox').remove();
    this.clearvars();
    this.unhighlight();
  };

  ns.loadListener = function() {
    var self = this;

    chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
      sender = null;
      if (request.method === "ns_initialize") {
        self.cleanup();
        self.settings = request.params.settings;
        self.manifest = request.params.manifest;
        self.tab      = request.params.tab;
        self.sendPage();
        if(self.names.length > 0) {
          self.highlight();
          self.makeToolBox();
          self.addNames();
          self.activateButtons();
          self.i18n();
        }
        sendResponse(self);
      } else {
        sendResponse({});
      }
    });
  };

  ns.init = function() {
    this.loadListener();
  };

  ns.init();

});