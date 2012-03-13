/*global $, jQuery, window, document, escape, alert, delete, self */

$(function() {

var NameSpotter = {
  status : "",
  names : {
    scientific : [],
    verbatim   : []
  },
  messages : {
    looking    : chrome.i18n.getMessage("looking"),
    no_names   : chrome.i18n.getMessage("no_names"),
    no_result  : chrome.i18n.getMessage("no_result"),
    no_content : chrome.i18n.getMessage("no_content"),
    error      : chrome.i18n.getMessage("error")
  },
  tab_url  : "",
  ws       : "http://gnrd.globalnames.org/find.json",
  settings : {},
  eol_content : []
};

NameSpotter.compareStringLengths = function(a, b) {
  "use strict";

  if (a.length < b.length) { return 1; }
  if (a.length > b.length) { return -1; }
  return 0;
};

NameSpotter.highlight = function() {
  "use strict";

  $.each(this.names.verbatim.sort(this.compareStringLengths), function() {
    $('body').highlight(this, { element: 'span', className: 'namespotter-highlight', wordsOnly: true });
  });
};

NameSpotter.unhighlight = function() {
  "use strict";

  $("body").unhighlight({element: 'span', className: 'namespotter-highlight'});
};

NameSpotter.makeList = function() {
  "use strict";

  this.names.scientific = this.names.scientific.sort();
};

NameSpotter.getEOLContent = function(obj, title, id, link) {
  "use strict";
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
        self.eol_content[title].tooltip += self.messages.no_content;
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

NameSpotter.makeToolTips = function() {
  "use strict";
  var self = this, title = "", config = {}, source = 'eol';

  if(self.settings.source){
    source = self.settings.source;
  }

  $('.namespotter-highlight').each(function() {
     title =  $(this).text();

     config = {
       content : {
         title : { text : title, button : true },
         text : '<p class="ui-tooltip-loader">' + self.messages.looking + '</p>',
         ajax : {
           url  : "http://eol.org/api/search/1.0/" + encodeURIComponent(title) + ".json",
           type : "GET",
           data : {},
           success : function(data, status) {
             status = null;
             if(data.totalResults === 0) {
               this.set('content.text', '<p class="ui-tooltip-error">' + self.messages.no_result + '</p>');
             } else {
               this.set('content.text', self.getEOLContent(this, title, data.results[0].id, data.results[0].link));
             }
           },
           error : function(){
             this.set('content.text', '<p class="ui-tooltip-error">' + self.messages.error + '</p>');
           }
        }
      },
      style: { classes: 'ui-tooltip-' + source + ' ui-tooltip-shadow ui-tooltip-rounded' },
      hide: { event: 'unfocus' },
      position: { viewport: $(window) }
    };

    $(this).qtip(config);
  });
};

NameSpotter.init = function() {
  "use strict";
  var self = this;

  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    sender = null;

    if (request.method === "NS_fromPopup") {
      // Send JSON data to popup
      self.tab_url = request.taburl;
      self.settings = $.parseJSON(request.settings);
      self.unhighlight();

      $.ajax({
        type : "POST",
        data : { input : $('body').text(), unique : true },
        url  : self.ws,
        success : function(data) {
          self.status = "ok";
          if(data.names.length === 0) {
            self.status = "nothing";
          } else {
            $.each(data.names, function(index, value) {
              index = null;
              self.names.scientific.push(value.scientificName.replace(/[\[\]]/gi,""));
              self.names.verbatim.push(value.verbatim);
            });
          }

          self.highlight();
          self.makeList();
          self.makeToolTips();

          sendResponse(self);
        },
        error : function() {
          self.status = "failed";
          sendResponse(self);
        }
      });

      // Send JSON data to background page
      chrome.extension.sendRequest({method: "NS_fromContentScript"}, function(response) {
        //user input from popup could be fed to background page
      });
    } else {
      sendResponse({}); // snub them.
    }
  });
};

NameSpotter.init();

});