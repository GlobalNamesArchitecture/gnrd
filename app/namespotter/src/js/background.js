chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
  // From content script.
  if (sender.tab) {
    if (request.method == "NS_fromContentScript") {
      sendResponse({ status: "OK"} );
    } else {
      sendResponse({}); // snub them.
    }
  }
});

function settings() {
  return localStorage["namespotter"] || "";
}