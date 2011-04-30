const {Cc,Ci,Cu} = require("chrome");
const fullscreen  = require("fullscreen");
const url         = require("url");
var camera = require("canvas-proxy");
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

      }

    if(e.percentage>95){
      syncTabs(browserUnique);
      console.log("ChromelssLoad done")
    }else{
     
    }
  },false);

  newBrowser.addEventListener("ChromelessSecurityChange", function (e) {
    $("#awesomeBox").attr("class","security_"+e.state);
  },false);

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

