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
    browserRef.contentWindow;
    var src=camera.full_snapshot(browserRef,$(browserRef.contentDocument).width(),$(browserRef.contentDocument).height(),console);
    console.log("#######"+$(browserRef).attr("becksrc"));
    var becksrc = $(browserRef).attr("becksrc");
    $(browserRef).remove();
    sendImage(becksrc,src);
    console.log($("iframe").size())
  } catch (i) { 
    console.log("canvas shot error");
    console.log(i);
    console.log(i.message); 
    console.log(i.lineNumber); 
  } 
} 

function sendImage(url,data){
  console.log("sending image (fax noise):"+url)
                                           console.log(window.ssid)
                                           webSocket.send( window.ssid+"||||thunbnail||||"+url+"||||"+data);
};
document.getElementById("browserContentArea").addEventListener("DOMNodeInserted", function(e){ 
  console.log(e.target.tagName)
  if(e.target.tagName==="IFRAME"){
    currentIframeElementId = currentIframeElementId  = e.target.getAttribute("id");
    var iframeElement = e.target;
  alert(iframeElement);
    var pm = require('web-content').ProgressMonitor();
    pm.on('title-change', function(title) {
      var evt = document.createEvent("HTMLEvents");
      evt.initEvent("ChromelessDOMTitleChange", true, false);
      evt.title = title;
      iframeElement.dispatchEvent(evt);
    });
    pm.on('progress', function(percentage) {
      var evt = document.createEvent("HTMLEvents");
      evt.initEvent("ChromelessDOMProgress", true, false);
      evt.percentage = percentage;
      iframeElement.dispatchEvent(evt);
    });
    pm.on('load-start', function() {
      var evt = document.createEvent("HTMLEvents");
      evt.initEvent("ChromelessDOMLoadStart", true, false);
      iframeElement.dispatchEvent(evt);
    });
    pm.on('load-stop', function() {
      var evt = document.createEvent("HTMLEvents");
      evt.initEvent("ChromelessDOMLoadStop", true, false);
      iframeElement.dispatchEvent(evt);
    });
    pm.on('security-change', function(e) {
      var evt = document.createEvent("HTMLEvents");
      evt.initEvent("ChromelessDOMSecurityChange", true, false);
      evt.state = e.state; 
      evt.strength = e.state; 
      iframeElement.dispatchEvent(evt);
    });
    var currentIframeElementId = iframeElement.getAttribute("id");
    document.getElementById("browserContentArea").addEventListener("DOMNodeRemoved", function(e){ 
      if(e.target.getAttribute("id") == currentIframeElementId) { 
        console.log("It's me!, detaching "); 
        pm.detach();
      } 
    }, false);
    pm.attach(iframeElement);
  }
},false);
function newTab() { 
  var newBrowser = makeBrowser();
  var uniqueId   = Math.random();
  var browserUnique = "browser_unique_"+uniqueId;
  browserTabs.push(newBrowser);
  newBrowser.setAttribute("id",browserUnique);
  newBrowser.addEventListener("ChromelessDOMProgress",function(e){
    alert(e);
  },false);
  setTimeout(function(){
    // snap a shot and remove iframe
    if(document.getElementById(browserUnique)){
      wc.stopload(document.getElementById(browserUnique));
      syncTabs(browserUnique);    
    }
  },1000);

  console.log(browserUnique);
  console.log($("iframe").size());
  document.getElementById("browserContentArea").appendChild(newBrowser);
  selectBrowser(newBrowser);

  return browserUnique;
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
  console.log($("iframe").size());
  console.log(window.ssid);
  webSocket.send( window.ssid+"||||ping");

},2000)


var webSocket = new WebSocket("ws://0.0.0.0:8080");
webSocket.onopen = function(evt) {
};
webSocket.onmessage = function(evt) {
  console.log("Got message")
    var message =evt.data;
  console.log("%%%%%%%"+message)
    if(message.match(/beck:/)){
      var browserUnique = newTab();
      console.log("got uniq")

        var fragment = $.trim(message.replace("beck:",""));
      $("#"+browserUnique).attr("src", url.guess(fragment));
      $("#"+browserUnique).attr("becksrc", fragment);
      console.log("message set:"+"#"+browserUnique);
    }else if(message.match(/ssid:/)){
      console.log("__________sid:"+message)
        window.ssid= $.trim(message.replace("ssid:",""));
    }else{
      console.log("Unknown message");
      console.log(message);
    }

};
webSocket.onclose = function(evt) {
  webSocket = new WebSocket("ws://0.0.0.0:8080");

};


