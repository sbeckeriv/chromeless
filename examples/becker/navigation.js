var Navigation = function(){
  var that;
  that.stop = function() { 
    var frame = document.getElementById("contentFrame");
    require("iframe-controls").stopload(frame);
  };
  that.current_uri = function(){
    $("#urlinput").val()
  };
  that.navigate(value) {
    // invoked when the user hits the go button or hits enter in url box
    var input = $.trim(value);
    // let's try to turn user input into a well formed url using the
    // 'url' library's guess function.
    input = url.guess(input);

    // now trigger navigation
    $("#contentFrame").attr("src", input);
  };
  that.reload = function(){


  };
  return that;
};
