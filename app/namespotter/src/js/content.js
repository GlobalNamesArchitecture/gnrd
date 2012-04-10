/*global $, jQuery, window, document, escape, alert, delete, self, chrome */

$(function() {

  "use strict";

  var ns = {
    status : "",
    names  : [],
    keys   : {},
    messages : {
      looking    : chrome.i18n.getMessage("content_looking"),
      no_names   : chrome.i18n.getMessage("popup_no_names"),
      no_result  : chrome.i18n.getMessage("content_no_result"),
      no_content : chrome.i18n.getMessage("content_no_content"),
      error      : chrome.i18n.getMessage("error")
    },
    tab_url  : "",
    manifest : {},
    settings : {},
    eol_content : []
  };

  ns.compareStringLengths = function(a, b) {
    if (a.length < b.length) { return 1; }
    if (a.length > b.length) { return -1; }
    return 0;
  };

  ns.highlight = function() {
    var self = this;
    $('body').highlight(this.verbatim(), { className : 'namespotter-highlight', wordsOlny : true });
    $('.namespotter-highlight').each(function() {
      $(this).attr("data-highlight", self.keys[$(this).text()]);
    });
  };

  ns.verbatim = function() {
    var verbatim = [], self = this;

    $.each(this.names, function() {
      verbatim.push(this.verbatim);
      self.keys[this.verbatim] = [];
      self.keys[this.verbatim].push(encodeURIComponent(this.scientificName.replace(/[\[\]]/gi,"")));
    });
    return verbatim.sort(this.compareStringLengths);
  };

  ns.unhighlight = function() {
    $('.namespotter-highlight').each(function() {
      $(this).qtip('destroy');
    });
    $("body").unhighlight({element: 'span', className: 'namespotter-highlight'});
  };

  ns.getEOLContent = function(obj, title, id, link) {
    var self = this, vernaculars = [], images = [], descriptions = [];

    $.ajax({
      type : "GET",
      async : false,
      url : "http://eol.org/api/pages/1.0/" + id + ".json?videos=0&amp;common_names=1&amp;images=2&amp;details=0&amp;subjects=GeneralDescription&amp;text=1",
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
              descriptions.push(value.description || "");
            }
          });
          self.eol_content[title].tooltip += (images.length > 0) ? '<div class="ui-tooltip-images">' + images.join("") + '</div>' : '';
          self.eol_content[title].tooltip += (descriptions.length > 0) ? '<div class="ui-tooltip-description">' + descriptions.join("<br>") + '</div>' : '';
        }
        if(data.vernacularNames.length === 0 && data.dataObjects.length === 0) {
          self.eol_content[title].tooltip += '<p class="ui-tooltip-error">' + self.messages.no_content + '</p>';
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

    $('.namespotter-highlight').each(function() {
       title =  $(this).attr("data-highlight") || "";
       config = {
         content : {
           title : { text : decodeURIComponent(title), button : true },
           text : '<p class="ui-tooltip-loader">' + self.messages.looking + '</p>',
           ajax : {
             url  : "http://eol.org/api/search/1.0/" + title.replace(/[\., ]/g, "+") + ".json", //TODO: replace with GNI
             type : "GET",
             data : {},
             success : function(data, status) {
               status = null;
               if(data.totalResults === 0) {
                 this.set('content.text', '<p class="ui-tooltip-error">' + self.messages.no_result + '</p>');
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
    this.names = [];
    this.unhighlight();
  };

  ns.init = function() {
    var self = this;

    chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
      sender = null;

      if (request.method === "ns_fromPopup") {
        // Send JSON data to popup
        self.cleanup();
        self.tab_url = request.taburl;
        self.settings = request.settings;
        self.manifest = request.manifest;
        $.ajax({
          type : "POST",
          data : { input : $('body').text(), unique : true },
          url  : self.manifest.namespotter.ws,
          success : function(data) {
            self.status = "ok";
            if(data.names.length === 0) {
              self.status = "nothing";
            } else {
              self.names = data.names;
            }
            self.highlight();
            self.makeToolTips();
            sendResponse(self);
          },
          error : function() {
            self.status = "failed";
            sendResponse(self);
          }
        });

        // Send JSON data to background page
        chrome.extension.sendRequest({method: "ns_fromContentScript"}, function(response) {
          //user input from popup could be fed to background page
          response = null;
        });
      } else {
        sendResponse({}); // snub them.
      }
    });
  };

  ns.init();

});