var webSocket = new WebSocket("ws://0.0.0.0:8080");
webSocket.onopen = function(evt) {
  alert("open");
};
webSocket.onmessage = function(evt) {
  var message =evt.data;
  if(message==/url:/){
    if(browserTabs.length<1){ newTab();  }
    browserUniqueId = $(".browser_selected").attr("id");
    var fragment = $.trim(evt.data);
    $(".browser_selected").attr("src", url.guess(fragment));
  }else(alert(message)}

};
webSocket.onclose = function(evt) {
  alert("Connection closed.");
};


