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

$(function() {

  "use strict";

  var ns = {
    tab         : {},
    settings    : {},
    response    : { names : [] },
    scrub       : ['select', 'input', 'textearea', 'script', 'style', 'noscript', 'img']
  };

  ns.compareStringLengths = function(a, b) {
    if (a.length < b.length) { return 1;  }
    if (a.length > b.length) { return -1; }
    return 0;
  };

  ns.verbatim = function() {
    var verbatim = [], self = this;

    $.each(this.response.names, function() {
      verbatim.push(this.verbatim);
    });
    return verbatim.sort(this.compareStringLengths);
  };

  ns.highlight = function() {
    var self = this;

    $('body').highlight(this.verbatim(), { className : 'namespotter-highlight', wordsOnly : true });
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
            return parseInt($(e).css('z-index'),10) || 100000;
          }
        }));

    $('#namespotter-toolbox').css('z-index', maxZ+1);
    $('#namespotter-names').resizer();

    $('.namespotter-close').click(function(e) {
      e.preventDefault();
      $('#namespotter-toolbox').remove();
      self.unhighlight();
      chrome.extension.sendRequest({ method : "ns_closed", tab : self.tab });
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

    this.cleanup();
    chrome.extension.sendRequest({ method : "ns_saveSettings", params : data });
  };

  ns.addNames = function() {
    var self = this, list = "", encoded = "", name = "", scientific = [];

    $.each(self.response.names, function() {
      name = this.scientificName.replace(/[\[\]]/gi,"");
      if($.inArray(name, scientific) === -1) { scientific.push(name); }
    });
    scientific.sort();

    $.each(scientific, function() {
      encoded = encodeURIComponent(this);
      list += '<li><input type="checkbox" id="ns-' + encoded + '" name="names[' + encoded + ']" value="' + this + '"><label for="ns-' + encoded + '">' + this + '</label></li>';
    });
    $('#namespotter-names-list ul').html("").append(list);
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
    var regexS  = "[\\?&]" + name + "=([^&#]*)",
        regex   = new RegExp(regexS),
        results = regex.exec(this.tab.url);

    if(results === null) {
      return "";
    }
    return decodeURIComponent(results[1].replace(/\+/g, " "));
  };

  ns.sendPage = function() {
    var self    = this,
        engine  = (self.settings && self.settings.engine) ? self.settings.engine : null,
        url     = self.tab.url,
        message = { tab : self.tab, data : { unique : true  } },
        ext     = url.split('.').pop().toLowerCase(),
        body    = "";

    if(url.indexOf("docs.google.com") !== -1 && ext === "pdf") {
      message.data.url = self.getParameterByName('url');
    } else if(ext === "pdf") {
      message.data.url = url;
    } else {
      body = $('body').clone();
      $.each(self.scrub, function() {
        body.find(this).remove();
      });
      message.data.input = body.text().replace(/\s+/g, " ");
    }
    
    if(engine) { message.data.engine = engine; }

    chrome.extension.sendRequest({ method : "ns_content", params : message }, function(response) {
      if(response.total > 0) {
        self.response = response;
        self.highlight();
        self.makeToolBox();
        self.addNames();
        self.activateButtons();
        self.i18n();
      }
    });
  };

  ns.clearvars = function() {
    this.tab        = {};
    this.settings   = {};
    this.response   = { names : [] };
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
        self.tab = request.params.tab;
        self.settings = request.params.settings;
        self.sendPage();
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