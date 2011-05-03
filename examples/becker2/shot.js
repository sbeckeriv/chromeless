
var currSelected   = null; 
var browserTabs    = new Array();
var shotQueue = new Array();

function makeBrowser() { 
  var browser = document.createElement("iframe");
  $(browser).addClass("browser");
  return browser;
} 

function selectBrowser(browserRef) { 
  $(".browser").removeClass("browser_selected");
  $(".browser").addClass("browser_hidden");
  $(browserRef).removeClass("browser_hidden");
  $(browserRef).addClass("browser_selected");
  var refBrowserId = $(browserRef).attr("id");
  var uniqueId = refBrowserId.split("browser_unique_")[1];
  currSelected = uniqueId; 
} 

function canvasShot(browserRef, thumbImageRef) { 
  try { 
    selectBrowser(browserRef);
    src=camera.full_snapshot(browserRef,$(browserRef.contentDocument).width(),$(browserRef.contentDocument).height(),console);
    console.log("#######"+$(browserRef).attr("becksrc"));

    sendImage($(browserRef).attr("becksrc"),src);
    $(browserRef).remove();
    console.log($("iframe").size())
  } catch (i) { 
    console.log(i);
    console.log(i.message); 
    console.log(i.lineNumber); 
  } 
} 

function sendImage(url,data){
  console.log(window.ssid)
    webSocket.send( window.ssid+"||||thunbnail||||"+url+"||||"+data);
};

function newTab() { 
  var newBrowser = makeBrowser();
  var uniqueId   = Math.random();
  var browserUnique = "browser_unique_"+uniqueId;

  browserTabs.push(newBrowser);
  newBrowser.setAttribute("id",browserUnique);
  newBrowser.addEventListener("ChromelessLoadProgress",function (e) { 
    try{
      console.log("ChromelssLoad "+$(document.getElementById(browserUnique)).attr("becksrc")+" "+e.percentage)
    }catch(e){
      console.log("error:Chromeprogress:"+e)
    }

    if(e.percentage>95){
      syncTabs(browserUnique);
      console.log("ChromelssLoad done")
    }else{

    }
  },false);
  console.log(browserUnique)
  console.log($("iframe").size())
    document.getElementById("browserContentArea").appendChild(newBrowser);
  selectBrowser(newBrowser);
} 

function syncTabs(refBrowserId) { 
  var uniqueId = refBrowserId.split("browser_unique_")[1];
  canvasShot(document.getElementById(refBrowserId),document.getElementById("image_unique_"+uniqueId));
  console.log("syncTabs done")
}

$(document).ready(function() {
  $("#browserHeader form").submit(function(e) {
    if(browserTabs.length<1) newTab();  
    browserUniqueId = $(".browser_selected").attr("id");
    var fragment = $.trim($("#awesomeBox").val());
    $(".browser_selected").attr("src", url.guess(fragment));
    return false; 
  });
  $("#browserHeader #buttonNew").click(function(e) {
    newTab();
    $("#awesomeBox").val("");
    $("#awesomeBox").focus();
    return false; 
  });
  $("#browserHeader #buttonPersist").click(function(e) {
    $(".browser").removeClass("browser_hidden");
    return false; 
  });
  $("#browserHeader #buttonFull").click(function(e) {
    fullscreen.toggle(window);
    return false; 
  });
});
var watcher = setInterval(function(){
  console.log($("iframe").size())
  webSocket.send( window.ssid+"||||ping");

},2000)


var webSocket = new WebSocket("ws://0.0.0.0:8080");
webSocket.onopen = function(evt) {
};
webSocket.onmessage = function(evt) {
  var message =evt.data;
  console.log("%%%%%%%"+message)
    if(message.match(/beck:/)){
      window.newTab();
      browserUniqueId = $(".browser_selected").attr("id");
      var fragment = $.trim(message.replace("beck:",""));
      $(".browser_selected").attr("src", url.guess(fragment));
      $(".browser_selected").attr("becksrc", fragment);


    }else if(message.match(/ssid:/)){
      console.log("__________sid"+message)


        window.ssid= $.trim(message.replace("ssid:",""));
    }else{
      //alert(message);
    }

};
webSocket.onclose = function(evt) {
  console.log(evt)
    webSocket = new WebSocket("ws://0.0.0.0:8080");

};


