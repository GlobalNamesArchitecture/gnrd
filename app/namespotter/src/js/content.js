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

  var ns = {
    status : "",
    names  : [],
    keys   : {},
    scientific : [],
    messages : {
      tooltip_looking    : chrome.i18n.getMessage("tooltip_looking"),
      tooltip_no_result  : chrome.i18n.getMessage("tooltip_no_result"),
      tooltip_no_content : chrome.i18n.getMessage("tooltip_no_content"),
      tooltip_source     : chrome.i18n.getMessage("tooltip_source"),
      tooltip_more       : chrome.i18n.getMessage("tooltip_more"),
      toolbox_no_names   : chrome.i18n.getMessage("toolbox_no_names"),
      error      : chrome.i18n.getMessage("error")
    },
    manifest : {},
    settings : {},
    eol_content : []
  };

  ns.compareStringLengths = function(a, b) {
    if (a.length < b.length) { return 1; }
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
    var self = this;

    $.each($('.namespotter-highlight'), function() {
      $(this).qtip('destroy');
    });
    $('body').unhighlight({className: 'namespotter-highlight'});
  };

  ns.i18n = function() {
    $.each($("[data-namespotter-i18n]"), function() {
      var message = chrome.i18n.getMessage($(this).attr("data-namespotter-i18n"));
      $(this).text(message);
    });
  };

  ns.getEOLContent = function(obj, title, id, link) {
    var self = this, vernaculars = [], images = [], descriptions = [];

    $.ajax({
      type : "GET",
      async : false,
      url : "http://eol.org/api/pages/1.0/" + id + ".json?videos=0&amp;common_names=1&amp;images=4&amp;details=1&amp;subjects=GeneralDescription|Description|TaxonBiology&amp;text=1",
      success : function(data) {
        obj.set('content.title.text', '<a href="' + link + '" target="_blank">' + data.scientificName + '</a>');
        self.eol_content[title] = {
          scientificName : data.scientificName,
          tooltip        : ""
        };
        if(data.vernacularNames.length > 0) {
          $.each(data.vernacularNames, function(index, value) {
            index = null;
            vernaculars.push(value.vernacularName);
          });
          self.eol_content[title].tooltip += '<div class="ui-tooltip-vernaculars">' + vernaculars.join(", ") + '</div>';
        }
        if(data.dataObjects.length > 0) {
          $.each(data.dataObjects, function(index, value) {
            index = null;
            if(value.mimeType && value.mimeType.indexOf("image") !== -1) {
              images.push('<img src="' + value.eolThumbnailURL + '" title="' + escape(value.title || "") + '" />');
            }
            if(value.mimeType && value.mimeType.indexOf("text") !== -1) {
              var description = value.description || "",
                  source      = (value.source) ? '<br><span class="ui-tooltip-source">[<a href="' + value.source + '" target="_blank">' + self.messages.tooltip_source + '</a>]</span>' : '';
              descriptions.push(description + source);
            }
          });
          self.eol_content[title].tooltip += (images.length > 0) ? '<div class="ui-tooltip-images">' + images.join("") + '</div>' : '';
          self.eol_content[title].tooltip += (descriptions.length > 0) ? '<div class="ui-tooltip-description">' + descriptions.join("<br>") + '</div>' : '';
        }
        if(data.vernacularNames.length === 0 && data.dataObjects.length === 0) {
          self.eol_content[title].tooltip += '<p class="ui-tooltip-error">' + self.messages.tooltip_no_content + '</p>';
        } else {
          self.eol_content[title].tooltip += '<p class="ui-tooltip-link"><a href="' + link + '" target="_blank">' + self.messages.tooltip_more + '</a>';
        }
      },
      error : function() {
        self.eol_content[title] = {
          scientificName : title,
          tooltip        : '<p class="ui-tooltip-error">' + self.messages.error + '</p>'
        };
      }
    });

    return self.eol_content[title].tooltip;
  };

  ns.makeToolTips = function() {
    var self = this, title = "", config = {}, source = 'eol';

    if(self.settings !== null && self.settings.source !== undefined){
      source = self.settings.source;
    }

    $.each($('.namespotter-highlight'), function() {
       title =  $(this).attr("data-highlight") || "";
       config = {
         content : {
           title : { text : decodeURIComponent(title), button : true },
           text : '<p class="ui-tooltip-loader">' + self.messages.tooltip_looking + '</p>',
           ajax : {
             url  : "http://eol.org/api/search/1.0/" + title.replace(/[\., ]/g, "+") + ".json", //TODO: replace with GNI
             type : "GET",
             data : {},
             success : function(data, status) {
               status = null;
               if(data.totalResults === 0) {
                 this.set('content.text', '<p class="ui-tooltip-error">' + self.messages.tooltip_no_result + '</p>');
               } else {
//TODO: replace with settings as is done with style
                 this.set('content.text', self.getEOLContent(this, title, data.results[0].id, data.results[0].link));
               }
             },
             error : function(){
               this.set('content.text', '<p class="ui-tooltip-error">' + self.messages.error + '</p>');
             }
          }
        },
        show : { solo : true },
        style: { classes: 'ui-tooltip-' + source + ' ui-tooltip-shadow ui-tooltip-rounded' },
        hide: { event: 'unfocus', fixed: true },
        position: { viewport: $(window) }
      };

      $(this).qtip(config);
    });
  };

  ns.cleanup = function() {
    $('#namespotter-toolbox').remove();
    this.status = "";
    this.names = [];
    this.keys = {};
    this.scientific = [];
    this.manifest = {};
    this.settings = {};
    this.eol_content = [];
    this.unhighlight();
  };

  ns.makeToolBox = function() {
    var toolbox = '';

    $.ajax({
      type     : "GET",
      async    : false,
      url      : chrome.extension.getURL("/toolbox.html"),
      dataType : 'html',
      success  : function(data) {
        toolbox = data;
      }
    });
    $('body').prepend(toolbox);
    $('#namespotter-names').resizer();
    $('#namespotter-names-buttons a.close').click(function(e) {
      e.preventDefault();
      $('#namespotter-toolbox').remove();
    });
    $('#namespotter-names-buttons a.minimize').click(function(e) {
      e.preventDefault();
      $('#namespotter-names').height('36px');
      $('#namespotter-names-list').height('0px');
    });
    $('#namespotter-names-buttons a.maximize').click(function(e) {
      e.preventDefault();
      $('#namespotter-names').height('400px');
      $('#namespotter-names-list').height('436px');
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
    $('#namespotter-names-tools').show();
    $('#namespotter-select-all').click(function(e) {
      e.preventDefault();
      $.each($('input', '#namespotter-names-list'), function() {
        $(this).attr("checked", true);
      });
    });
    $('#namespotter-select-none').click(function(e) {
      e.preventDefault();
      $.each($('input', '#namespotter-names-list'), function() {
        $(this).attr("checked", false);
      });
    });
    $('#namespotter-select-copy').click(function(e) {
      e.preventDefault();
      chrome.extension.sendRequest({ method : "ns_clipBoard", names: $('form', '#namespotter-toolbox').serializeArray() });
    });

  };

  ns.analytics = function(category, action, label) {
    chrome.extension.sendRequest({ method : "ns_analytics", category : category, action : action, label : label });
  };

  ns.sendPage = function() {
    var self = this;

    $.ajax({
      type  : "POST",
      async : false,
      data  : { input : $('body').text(), unique : true },
      url   : self.manifest.namespotter.ws,
      success : function(data) {
        self.status = "ok";
        self.names = data.names;
      },
      error : function() {
        self.status = "failed";
      }
    });
  };

  ns.loadListener = function() {
    var self = this;

    chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
      if (request.method === "ns_fromBackground") {
        self.cleanup();
        self.settings = request.settings;
        self.manifest = request.manifest;
        self.sendPage();
        if(self.names.length > 0) {
          self.highlight();
          self.makeToolTips();
          self.makeToolBox();
          self.addNames();
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