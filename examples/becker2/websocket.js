var webSocket = new WebSocket("ws://0.0.0.0:8080");
webSocket.onopen = function(evt) {
};
webSocket.onmessage = function(evt) {
  var message =evt.data;
  if(message.match(/beck:/)){
     newTab();
    browserUniqueId = $(".browser_selected").attr("id");
    var fragment = $.trim(message.replace("beck:",""));
    $(".browser_selected").attr("src", url.guess(fragment));
  }else{
    //alert(message);
  }

};
webSocket.onclose = function(evt) {
  alert("Connection closed.");
};



