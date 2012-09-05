package lib.ui
{
  import flash.display.DisplayObjectContainer;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.geom.Rectangle;

  import lib.Point;

  public class Window
  {
    public function Window(newParent : DisplayObjectContainer,
                           newSize : lib.Point, newBackgroundSize : lib.Point,
                           layerCount : int,
                           newImages : ImageList,
                           newBorder : WindowBorder,
                           newBackground : MovieClip,
                           newMargin : int) : void
    {
      offset = new lib.Point(0, 0);
      screen = new lib.Point(0, 0);
      screenOffset = new lib.Point(0, 0);
      size = newSize.clone();
      moved = false;
      parent = newParent;
      backParent = new Sprite();
      parent.addChild(backParent);
      backParent.mouseEnabled = false;
      background = newBackground;
      margin = newMargin;
      backParent.addChild(background);
      border = newBorder;
      border.init(backParent);
      shouldClick = false;
      hasMoved = false;
      dragOrigin = null;
      background.addEventListener(MouseEvent.CLICK, click);
      background.addEventListener(MouseEvent.MOUSE_DOWN, dragBegin);
      background.stage.addEventListener(MouseEvent.MOUSE_UP, dragEnd);
      background.stage.addEventListener(MouseEvent.MOUSE_MOVE, dragMove);
      background.addEventListener(MouseEvent.MOUSE_MOVE, hover);
      background.addEventListener(MouseEvent.MOUSE_OVER, hover);
      background.addEventListener(MouseEvent.MOUSE_OUT, hoverOut);
      background.cacheAsBitmap = true;
      foreground = new Array(layerCount);
      var i : int = 0;
      for (; i < foreground.length; ++i)
      {
        foreground[i] = new Sprite();
        parent.addChild(foreground[i]);
        foreground[i].mouseChildren = false;
        foreground[i].mouseEnabled = false;
      }
      clickCommands = new Array();
      hoverCommands = new Array();
      scrollCommands = new Array();
      dragBeginCommands = new Array();
      dragEndCommands = new Array();
      dragMoveCommands = new Array();
      images = newImages;
      resizeBackground(newBackgroundSize);
    }

    public function cleanup() : void
    {
      for each (var clip in foreground)
      {
        clip.parent.removeChild(clip);
      }
      background.removeEventListener(MouseEvent.CLICK, click);
      background.removeEventListener(MouseEvent.MOUSE_DOWN, dragBegin);
      background.stage.removeEventListener(MouseEvent.MOUSE_UP, dragEnd);
      background.stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragMove);
      background.removeEventListener(MouseEvent.MOUSE_MOVE, hover);
      background.removeEventListener(MouseEvent.MOUSE_OVER, hover);
      background.removeEventListener(MouseEvent.MOUSE_OUT, hoverOut);
      border.cleanup();
      background.parent.removeChild(background);
      backParent.parent.removeChild(backParent);
    }

    public function resizeBackground(newSize : Point) : void
    {
      backgroundSize = null;
      if (newSize != null)
      {
        backgroundSize = newSize.clone();
      }
      setScreenSize();
      scrollWindow(new Point(0, 0));
    }

    public function resizeWindow(newSize : Point) : void
    {
      var center = getCenter();
      size = newSize.clone();
      size.x -= screenOffset.x;
      size.y -= screenOffset.y;
      setScreenSize();

      setCenter(center);
    }

    public function setScreenOffset(newScreenOffset : Point) : void
    {
      size.x = size.x - newScreenOffset.x + screenOffset.x;
      size.y = size.y - newScreenOffset.y + screenOffset.y;
      screenOffset = newScreenOffset.clone();
      setScreenSize();
      scrollWindow(new Point(0, 0));
    }

    function setScreenSize() : void
    {
/*
      screen.x = screenOffset.x;
      screen.y = screenOffset.y;
      if (backgroundSize != null)
      {
        if (backgroundSize.x < size.x)
        {
          screen.x += Math.floor((size.x - backgroundSize.x) / 2);
        }
        if (backgroundSize.y < size.y)
        {
          screen.y += Math.floor((size.y - backgroundSize.y) / 2);
        }
      }
      backParent.x = screen.x;
      backParent.y = screen.y;
      for each (var fore in foreground)
      {
        fore.x = screen.x;
        fore.y = screen.y;
      }
*/
    }

    public function addClickCommand(newCommand : Function) : void
    {
      clickCommands.push(newCommand);
    }

    public function addHoverCommand(newCommand : Function) : void
    {
      hoverCommands.push(newCommand);
    }

    public function addScrollCommand(newCommand : Function) : void
    {
      scrollCommands.push(newCommand);
    }

    public function addDragBeginCommand(newCommand : Function) : void
    {
      dragBeginCommands.push(newCommand);
    }

    public function addDragEndCommand(newCommand : Function) : void
    {
      dragEndCommands.push(newCommand);
    }

    public function addDragMoveCommand(newCommand : Function) :void
    {
      dragMoveCommands.push(newCommand);
    }

    public function getOffset() : lib.Point
    {
      return offset;
    }

    public function getSize() : lib.Point
    {
      return size;
    }

    public function getScreen() : lib.Point
    {
      return screen;
    }

    public function getCenter() : lib.Point
    {
      if (backgroundSize == null)
      {
        return new Point(0, 0);
      }
      else
      {
//        return new Point(Math.floor((backgroundSize.x - size.x)/2),
//                         Math.floor((backgroundSize.y - size.y)/2));
        return new Point(Math.floor(offset.x + size.x/2),
                         Math.floor(offset.y + size.y/2));
      }
    }

    public function isMoved() : Boolean
    {
      return moved;
    }

    public function clearMoved() : void
    {
      moved = false;
    }

    public function getLayer(layer : int) : Sprite
    {
      return foreground[layer];
    }

    public function scrollWindow(delta : lib.Point) : void
    {
      offset.plusEquals(delta);
      updatePos();
    }

    public function setCenter(newCenter : lib.Point) : void
    {
      setOffset(new lib.Point(newCenter.x - Math.floor(size.x/2),
                              newCenter.y - Math.floor(size.y/2)));
    }

    public function setOffset(newOffset : lib.Point) : void
    {
      offset.x = newOffset.x;
      offset.y = newOffset.y;
      updatePos();
    }

    public function updatePos() : void
    {
      moved = true;
      if (backgroundSize != null)
      {
//        var xMargin = Math.max(margin, - backgroundSize.x + size.x);
//        var yMargin = Math.max(margin, - backgroundSize.y + size.y);
        var xMargin = margin;
        var yMargin = margin;
        if (offset.x < 0 - margin)
        {
          offset.x = 0 - margin;
        }
        if (offset.x > backgroundSize.x - size.x + xMargin)
        {
          offset.x = backgroundSize.x - size.x + xMargin;
        }
        if (backgroundSize.x + 2*margin < size.x)
        {
          offset.x = (backgroundSize.x - size.x)/2;
        }
        if (offset.y < 0 - margin)
        {
          offset.y = 0 - margin;
        }
        if (offset.y >= backgroundSize.y - size.y + yMargin)
        {
          offset.y = backgroundSize.y - size.y + yMargin;
        }
        if (backgroundSize.y + 2*margin < size.y)
        {
          offset.y = (backgroundSize.y - size.y)/2;
        }

/*
        backParent.scrollRect = new Rectangle(
          Math.max(offset.x, 0),
          Math.max(offset.y, 0),
          Math.min(size.x, backgroundSize.x),
          Math.min(size.y, backgroundSize.y));
        if (offset.x < 0)
        {
          backParent.x = margin + offset.x;
        }
        if (offset.y < 0)
        {
          backParent.y = margin + offset.y;
        }
*/
        backParent.scrollRect = new Rectangle(offset.x, offset.y,
                                              size.x, size.y);
        border.update(offset, screen, backgroundSize, size);
      }
      else
      {
        var x = findBackOffset(offset.x, size.x);
        var y = findBackOffset(offset.y, size.y);
        backParent.scrollRect = new Rectangle(x, y, size.x, size.y);
      }
      runCommand(offset, scrollCommands);
    }

    function findBackOffset(val : int, mod : int) : int
    {
      var result = val % mod;
      if (result < 0)
      {
        result += mod;
      }
      return result;
    }

    public function toRelative(pos : Point) : Point
    {
      return new Point(pos.x - offset.x + screen.x,
                       pos.y - offset.y + screen.y);
    }

    public function swapLayers(first : int, second : int) : void
    {
      parent.swapChildren(foreground[first], foreground[second]);
    }

    function eventToPoint(event : MouseEvent) : Point
    {
      return new Point(Math.floor(event.stageX) + offset.x - screen.x,
                       Math.floor(event.stageY) + offset.y - screen.y);
    }

    function dragBegin(event : MouseEvent) : void
    {
      dragOrigin = eventToPoint(event);
      hasMoved = false;
      shouldClick = false;
      runCommand(eventToPoint(event), dragBeginCommands);
    }

    function dragEnd(event : MouseEvent) : void
    {
      if (! hasMoved)
      {
        shouldClick = true;
      }
      hasMoved = false;
      dragOrigin = null;
      runCommand(eventToPoint(event), dragEndCommands);
    }

    function isNotNear(left : Point, right : Point) : Boolean
    {
      return Math.abs(left.x - right.x) >= 5
        || Math.abs(left.y - right.y) >= 5;
    }

    function dragMove(event : MouseEvent) : void
    {
      var current = eventToPoint(event);
      if (hasMoved || (dragOrigin != null && isNotNear(current, dragOrigin)))
      {
        hasMoved = true;
        runCommand(eventToPoint(event), dragMoveCommands);
      }
    }

    function click(event : MouseEvent) : void
    {
      if (shouldClick)
      {
        runCommand(eventToPoint(event), clickCommands);
      }
    }

    function hover(event : MouseEvent) : void
    {
      runCommand(eventToPoint(event), hoverCommands);
    }

    function hoverOut(event : MouseEvent) : void
    {
      runCommand(null, hoverCommands);
    }

    function runCommand(pos : Point, commands : Array) : void
    {
      if (commands.length > 0)
      {
        for each (var command in commands)
        {
          var used = command(pos);
          if (used)
          {
            break;
          }
        }
      }

    }

    var offset : lib.Point;
    var screen : lib.Point;
    var screenOffset : lib.Point;
    var size : lib.Point;
    var backgroundSize : lib.Point;
    var moved : Boolean;
    var margin : int;
    var shouldClick : Boolean;
    var hasMoved : Boolean;
    var dragOrigin : Point;

    var parent : DisplayObjectContainer;
    var backParent : Sprite;
    var background : MovieClip;
    var border : WindowBorder;
    var foreground : Array;

    var clickCommands : Array;
    var hoverCommands : Array;
    var scrollCommands : Array;
    var dragBeginCommands : Array;
    var dragEndCommands : Array;
    var dragMoveCommands : Array;
    var images : ImageList;
  }
}
