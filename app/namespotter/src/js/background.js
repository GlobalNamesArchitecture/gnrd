chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
  // From content script.
  if (sender.tab) {
    if (request.method == "NS_fromContentScript") {
      sendResponse({ data: "Response from Background Page"} );
    } else {
      sendResponse({}); // snub them.
    }
  }
});