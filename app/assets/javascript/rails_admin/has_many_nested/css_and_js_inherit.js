function isInIFrame(){
  return  window.frameElement && window.frameElement.nodeName == "IFRAME";
}
window.inheritStylesAndJs= function(){

    // // Add an event listener.
    // addEventListener(document, 'customChangeEvent', function(e) {
    //   document.body.innerHTML = e.detail;
    // });
    function addEventListener(el, eventName, handler) {
      if (el.addEventListener) {
        el.addEventListener(eventName, handler);
      } else {
        el.attachEvent('on' + eventName, function() {
          handler.call(el);
        });
      }
    }

    // // Trigger the event.
    // triggerEvent(document, 'customChangeEvent', {
    //   detail: 'Display on trigger...'
    // });

    function triggerEvent(el, eventName, options) {
      var event;
      if (window.CustomEvent) {
        event = new CustomEvent(eventName, options);
      } else {
        event = document.createEvent('CustomEvent');
        event.initCustomEvent(eventName, true, true, options);
      }
      el.dispatchEvent(event);
    }


     if (window.parent) {
         var oHead = document.getElementsByTagName("head")[0];
         var arrStyleSheets = window.parent.document.getElementsByTagName("link");
         for (var i = 0; i < arrStyleSheets.length; i++){
             oHead.appendChild(arrStyleSheets[i].cloneNode(true));
         }

         var arrStyles = window.parent.document.getElementsByTagName("style");
         for (var j = 0; j < arrStyleSheets.length; j++){
             oHead.appendChild(arrStyles[j].cloneNode(true));
         }

         for (var k in window.parent.document.scripts){
             var parentScript = window.parent.document.scripts[k];
             var newScript = document.createElement('script');

             if(parentScript.src)
                 newScript.src = parentScript.src;

             if(parentScript.innerHTML)
                 newScript.innerHTML = parentScript.innerHTML;
             oHead.appendChild(newScript);
         }

         // Trigger any bound ready events
        if ( jQuery.fn.trigger ) {
            jQuery( document ).trigger( "ready" ).unbind( "ready" );
        }
     }
};

$(window).resize(function () {
  console.debug("window resized - firing resizeHeight on iframe");
  parentIframeAutoHeight();
});

$(window).scroll(function() {
  console.debug("window scroll - firing resizeHeight on iframe");
  parentIframeAutoHeight();
});

$(document).click(function() {
  console.debug("window click - firing resizeHeight on iframe");
  parentIframeAutoHeight();
});

function parentIframeAutoHeight(){
  if(isInIFrame() && window.parent){
    window.parent.resizeIframe("iframe.auto-resize-iframe");
    window.parent.iframeAutoHeight("iframe.auto-resize-iframe");
  }
}
parentIframeAutoHeight();

window.onload = function() {
   if(isInIFrame() && window.parent){
     parentIframeAutoHeight();
   }
   if (isInIFrame() && window.top && window.top.stopPjax){
     window.top.stopPjax();
   }
};

$(document).ready(function(){
  window.onload();
});

$(document).on('pjax:start', function(){
  if (isInIFrame() && window.top && window.top.stopPjax){
    window.top.stopPjax();
  }
});

$(document).on('pjax:stop', function(){
  if (isInIFrame() && window.top && window.top.startPjax){
    window.top.startPjax();
  }
});
