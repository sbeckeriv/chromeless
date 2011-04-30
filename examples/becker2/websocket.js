
var webSocket = new WebSocket("ws://0.0.0.0:8080");
webSocket.onopen = function(evt) {
};
webSocket.onmessage = function(evt) {
  var message =evt.data;
  console.log("%%%%%%%"+message)
  if(message.match(/beck:/)){
    newTab();
    browserUniqueId = $(".browser_selected").attr("id");
    var fragment = $.trim(message.replace("beck:",""));
    $(".browser_selected").attr("src", url.guess(fragment));
    $(".browser_selected").attr("becksrc", fragment);


  }else if(message.match(/ssid:/)){
    window.ssid= $.trim(message.replace("ssid:",""));
  }else{
    //alert(message);
  }

};
webSocket.onclose = function(evt) {
  console.log(evt)
  webSocket = new WebSocket("ws://0.0.0.0:8080");

};



