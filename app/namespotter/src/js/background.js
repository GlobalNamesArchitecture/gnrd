chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
  // From content script.
  if (sender.tab) {
    if (request.method == "ns_fromContentScript") {
      sendResponse({ status: "OK"} );
    } else {
      sendResponse({}); // snub them.
    }
  }
});

chrome.manifest = (function() {
  var manifestObject = false, xhr = new XMLHttpRequest();

  xhr.onreadystatechange = function() {
    if (xhr.readyState == 4) { manifestObject = JSON.parse(xhr.responseText); }
  };
  xhr.open("GET", chrome.extension.getURL('/manifest.json'), false);

  try {
    xhr.send();
  } catch(e) {
    console.log('Couldn\'t load manifest.json');
  }

  return manifestObject;
})();

function settings() {
  return localStorage.namespotter || {};
}