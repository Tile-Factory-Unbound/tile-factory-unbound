package lib.ui
{
  import flash.display.InteractiveObject;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.external.ExternalInterface;

  import lib.Point;

  public class MouseScroller
  {
    public function MouseScroller(newParent : InteractiveObject) : void
    {
      enabled = true;
      north = false;
      south = false;
      east = false;
      west = false;
      parent = newParent;
      counter = 0;
      parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
      parent.stage.addEventListener(MouseEvent.ROLL_OVER, mouseMove);
      parent.stage.addEventListener(Event.MOUSE_LEAVE, mouseLeave);
    }

    public function cleanup() : void
    {
      parent.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
      parent.stage.removeEventListener(MouseEvent.ROLL_OVER, mouseMove);
      parent.stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeave);
//      parent.removeEventListener(Event.ENTER_FRAME, enterFrame);
    }

    function mouseMove(event : MouseEvent) : void
    {
      north = false;
      south = false;
      east = false;
      west = false;
//      parent.removeEventListener(Event.ENTER_FRAME, enterFrame);
      updateMouse(Math.floor(event.stageX),
                  Math.floor(event.stageY),
                  scrollMargin);
    }

    function mouseLeave(event : Event) : void
    {
      updateMouse(Math.floor(parent.stage.mouseX),
                  Math.floor(parent.stage.mouseY),
                  scrollOutMargin);
//      parent.addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    function updateMouse(x : int, y : int, margin : int) : void
    {
      var size : lib.Point = new lib.Point(parent.stage.stageWidth,
                                           parent.stage.stageHeight);
      north = (y <= margin && withinGutter(size, x, y));
      south = (y > size.y - margin && withinGutter(size, x, y));
      east = (x > size.x - margin && withinGutter(size, x, y));
      west = (x <= margin && withinGutter(size, x, y));
      if (this.north || this.south || this.east || this.west)
      {
//        parent.addEventListener(Event.ENTER_FRAME, enterFrame);
      }
      else
      {
//        parent.removeEventListener(Event.ENTER_FRAME, enterFrame);
      }
    }

    function withinGutter(size : lib.Point, x : int, y : int) : Boolean
    {
      return x >= -outMargin && y >= -outMargin
        && x <= size.x + outMargin && y <= size.y + outMargin;
    }

    static var scrollIncrement : int = 15;

    public function enterFrame(window : Window) : void
    {
      if (enabled)
      {
        updateExternal();
        counter += 7;//Main.config.getValue(Config.SCROLL) + 1;
        if (counter >= maxScroll)
        {
          if (north)
          {
            window.scrollWindow(new lib.Point(0, -scrollIncrement));
          }
          if (south)
          {
            window.scrollWindow(new lib.Point(0, scrollIncrement));
          }
          if (east)
          {
            window.scrollWindow(new lib.Point(scrollIncrement, 0));
          }
          if (west)
          {
            window.scrollWindow(new lib.Point(-scrollIncrement, 0));
          }
          counter -= maxScroll;
        }
      }
    }

    public function enable() : void
    {
      this.enabled = true;
    }

    public function disable() : void
    {
      this.enabled = false;
    }

    function updateExternal() : void
    {
      if (mouseOut)
      {
        north = false;
        south = false;
        east = false;
        west = false;
      }
      else if (mousePos != null && ExternalInterface.available)
      {
        updateMouse(mousePos.x, mousePos.y, scrollOutMargin);
      }
    }

    var enabled : Boolean;
    var north : Boolean;
    var south : Boolean;
    var east : Boolean;
    var west : Boolean;
    var parent : flash.display.InteractiveObject;
    var counter : int;

    static function getBasePos(id : String) : lib.Point
    {
      var result : lib.Point = null;
      try
      {
        if (ExternalInterface.available)
        {
          var htmlJs : String
            = "function getPos() "
            + "{ "
            + "  var curleft = curtop = 0; "
            + "  var obj = document.getElementById('" + id + "'); "
            + "  if (obj.offsetParent) "
            + "  { "
            + "    do "
            + "    { "
            + "      curleft += obj.offsetLeft; "
            + "      curtop += obj.offsetTop; "
            + "    } while (obj = obj.offsetParent); "
            + "  } "
            + " return [curleft, curtop]; "
            + "}";
          var pos : * = flash.external.ExternalInterface.call(htmlJs);
          if (pos != null)
          {
            result = new lib.Point(pos[0],pos[1]);
          }
          else
          {
            trace("MouseScroller: Failed to get element position");
          }
        }
        else
        {
          trace("MouseScroller: External interface is unavailable");
        }
      }
      catch (e : Error)
      {
        trace("MouseScroller: " + e);
      }
      return result;
    }

    static public function trackMouse() : void
    {
      try
      {
        if (ExternalInterface.available)
        {
          var id : String = ExternalInterface.objectID;
          basePos = getBasePos(id);
          ExternalInterface.addCallback("mouseMoveCallback", setMousePosition);
          ExternalInterface.addCallback("mouseOutCallback", setMouseOut);
          ExternalInterface.addCallback("mouseOverCallback", clearMouseOut);
          var htmlJs : String
            = "function getPos() "
            + "{ "
            + "  document.onmousemove = function(e) "
            + "  { "
            + "    if (!e) "
            + "    { "
            + "      if (window.event) "
            + "      { "
            + "        e = window.event; "
            + "      } "
            + "      else "
            + "      { "
            + "        return; "
            + "      } "
            + "    } "
            + "    if (typeof (e.pageX) == 'number') "
            + "    { "
            + "      var xcoord = e.pageX; "
            + "      var ycoord = e.pageY; "
            + "    } "
            + "    else if (typeof (e.clientX) == 'number') "
            + "    { "
            + "      var xcoord = e.clientX; "
            + "      var ycoord = e.clientY; "
            + "      var badOldBrowser "
            + "        = (window.navigator.userAgent.indexOf('Opera') + 1) "
            + "          || (window.ScriptEngine "
            + "              && ScriptEngine().indexOf('InScript') + 1) "
            + "          || (navigator.vendor == 'KDE'); "
            + "      if (!badOldBrowser) "
            + "      { "
            + "        if (document.body && (document.body.scrollLeft "
            + "                              || document.body.scrollTop)) "
            + "        { "
            + "          xcoord += document.body.scrollLeft; "
            + "          ycoord += document.body.scrollTop; "
            + "        } "
            + "        else if (document.documentElement "
            + "                 && (document.documentElement.scrollLeft "
            + "                     || document.documentElement.scrollTop)) "
            + "        { "
            + "          xcoord += document.documentElement.scrollLeft; "
            + "          ycoord += document.documentElement.scrollTop; "
            + "        } "
            + "      } "
            + "    } "
            + "    var obj = document.getElementById('" + id
            +                  "').mouseMoveCallback(xcoord, ycoord); "
            + "  }; "
            + "  window.onmouseout = function(e) "
            + "  { "
            + "    if (!e) "
            + "    { "
            + "      e = window.event; "
            + "    } "
            + "    var isAChildOf = function(_parent, _child) "
            + "    { "
            + "      if (_parent === _child) "
            + "      { "
            + "        return false; "
            + "      } "
            + "      while (_child && _child !== _parent) "
            + "      { "
            + "        _child = _child.parentNode; "
            + "      } "
            + "      return _child === _parent; "
            + "    }; "
            + "    var relTarget = e.relatedTarget || e.toElement; "
            + "    if (window === relTarget || isAChildOf(window, relTarget)) "
            + "    { "
            + "      return; "
            + "    } "
            + "    var obj = document.getElementById('" + id
            +                  "').mouseOutCallback(); "
            + "    }; "
            + "  window.onmouseover = function(e) "
            + "  { "
            + "    if (!e) "
            + "    { "
            + "      e = window.event; "
            + "    } "
            + "    var isAChildOf = function(_parent, _child) "
            + "    { "
            + "      if (_parent === _child) "
            + "      { "
            + "        return false; "
            + "      } "
            + "      while (_child && _child !== _parent) "
            + "      { "
            + "        _child = _child.parentNode; "
            + "      } "
            + "      return _child === _parent; "
            + "    }; "
            + "    var relTarget = e.relatedTarget || e.fromElement; "
            + "    if (window === relTarget || isAChildOf(window, relTarget)) "
            + "    { "
            + "      return; "
            + "    } "
            + "    var obj = document.getElementById('" + id
            +                  "').mouseOverCallback(); "
            + "  }; "
            + "  return true "
            + "}";
          var result : * = flash.external.ExternalInterface.call(htmlJs);
          if (result != null)
          {
            //trace(result);
          }
          else
          {
            //trace("MouseScroller: Failed to get element position");
          }
        }
        else
        {
          trace("MouseScroller: External interface is unavailable");
        }
      }
      catch (e : Error)
      {
        trace("MouseScroller " + e);
      }
    }

    static function setMousePosition(x : int,y : int) : void
    {
      if (basePos != null)
      {
        mousePos = new lib.Point(x - basePos.x, y - basePos.y);
      }
      else
      {
        mousePos = new lib.Point(x, y);
      }
//      Game.view.mouseScroller.updateExternal();
    }

    static function setMouseOut() : void
    {
      mouseOut = true;
//      Game.view.mouseScroller.updateExternal();
    }

    static function clearMouseOut() : void
    {
      mouseOut = false;
//      Game.view.mouseScroller.updateExternal();
    }

    static var basePos : lib.Point = null;
    static var mousePos : lib.Point = null;
    static var mouseOut : Boolean = false;

    static var maxScroll : int = 7;
    static var scrollMargin : int = 5;
    static var scrollOutMargin : int = 100;
    static var outMargin : int = 50;
  }
}
