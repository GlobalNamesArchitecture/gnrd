(function($){
  var ele,staticOffset,grip,
      iLastMousePos = 0,
      iMin = 36;

  $.fn.resizer = function(){
    return this.each(function(){
      ele = $(this).addClass('processed'),
      staticOffset = null;
      $(this).wrap('<div class="resizable-ele"><span></span></div>')
             .parent()
             .prepend($('<div class="namespotter-grippie"></div>').bind("mousedown", { el : this }, startDrag));

      var grippie = $('div.namespotter-grippie', $(this).parent())[0];
      grippie.style.marginRight = (grippie.offsetWidth - $(this)[0].offsetWidth) + 'px'
    });
  };

  function startDrag(e){
    ele = $(e.data.el);
    ele.blur();
    iLastMousePos = mousePosition(e).y;
    staticOffset = ele.height() - iLastMousePos;
    $(document).mousemove(performDrag).mouseup(endDrag);

    return false;
  }

  function performDrag(e){
    var iThisMousePos = mousePosition(e).y,
        iMousePos = staticOffset + iThisMousePos;

    if(iLastMousePos >= iThisMousePos){
      iMousePos -= 5;
    }

    iLastMousePos = iThisMousePos;
    iMousePos = Math.max(iMin,iMousePos);
    ele.height(iMousePos + 'px');

    $('#namespotter-names-list').height((ele.height() - iMin) + 'px');

    if(iMousePos < iMin){
      endDrag(e);
    }

    return false;
  }

  function endDrag(e){
    $(document).unbind('mousemove',performDrag).unbind('mouseup',endDrag);
    ele.focus();
    ele = null;
    staticOffset = null;
    iLastMousePos = 0;
  }

  function mousePosition(e){
    return { x : e.clientX + document.documentElement.scrollLeft, y :  document.documentElement.scrollTop - e.clientY }
  }

}(jQuery));