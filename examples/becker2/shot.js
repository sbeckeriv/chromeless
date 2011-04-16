

const {Cc,Ci,Cu} = require("chrome");

const fullscreen  = require("fullscreen");
const url         = require("url");
var camera = require("canvas-proxy");


//fullscreen.toggle(window);

var currentBrowser = null; 
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
  if(currSelected) { 
    //document.getElementById("thumb_unique_"+currSelected).setAttribute("class","thumb");
  } 
 // document.getElementById("thumb_unique_"+uniqueId).setAttribute("class","thumb thumb_selected");
  currSelected = uniqueId; 
} 

function canvasShot(browserRef, thumbImageRef) { 
  try { 
  //  thumbImageRef.width="1";
   // thumbImageRef.height="1";
selectBrowser(browserRef)
    console.log($(browserRef.contentWindow).width())
    console.log($(browserRef.contentDocument).width())
    console.log(browserRef.contentDocument.title)
    console.log(browserRef.src)
    // window.innerHeight=$(browserRef.contentDocument).height();
    //  window.innerWidth= $(browserRef.contentDocument).width()+4; // shrinks 4 px each time


    src=camera.full_snapshot(browserRef,$(browserRef.contentDocument).width(),$(browserRef.contentDocument).height(),console);
    console.log(browserRef.src)

    //alert(browserRef.contentDocument.body.scrollHeight)
    sendImage(browserRef.src,src);
  } catch (i) { 
    console.log(i.message); 
    console.log(i.lineNumber); 
  } 
} 




function sendImage(url,data){
  //  setTimeout(function(){
  webSocket.send( "thunbnail||||"+url+"||||"+data);
  //  },1)
};

function newTab() { 
  var newBrowser = makeBrowser();
  var uniqueId   = Math.random();
  var browserUnique = "browser_unique_"+uniqueId;

  browserTabs.push(newBrowser);
  newBrowser.setAttribute("id",browserUnique);

  // Update thumbnails of the iframe when DOM is setup, and
  // again when the page is fully loaded.
  newBrowser.addEventListener("ChromelessDOMSetup",function (e) { 
    //syncTabs(browserUnique);
  },false);

  // sync again after load is compelete
  newBrowser.addEventListener("ChromelessLoadProgress",function (e) { 
    console.log(e.percentage)
    if(e.percentage>90)
    syncTabs(browserUnique);
  },false);

  newBrowser.addEventListener("ChromelessSecurityChange", function (e) {
    $("#awesomeBox").attr("class","security_"+e.state);
  },false);

  document.getElementById("browserContentArea").appendChild(newBrowser);
  
  selectBrowser(newBrowser);
  currentBrowser = newBrowser;
} 

function syncTabs(refBrowserId) { 
  var uniqueId = refBrowserId.split("browser_unique_")[1];

  canvasShot(document.getElementById(refBrowserId),document.getElementById("image_unique_"+uniqueId));
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

