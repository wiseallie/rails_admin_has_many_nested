
function resizeIframe(selector){
  $(selector).iFrameResize({
    checkOrigin: false,
    log: true,
    autoResize: true,
    resizedCallback: function(iframe,height,width,type){
      iframeAutoHeight($(iframe));
    },
    scrollCallback: function(x,y){
      // iframeAutoHeight($(this));
    },
  });
}

function iframeAutoHeight(selector){
  $(selector).iframeAutoHeight({debug: true});
}

function startPjax(){
  $(document).trigger('pjax:start');
}

function stopPjax(){
  $(document).trigger('pjax:stop');
}
