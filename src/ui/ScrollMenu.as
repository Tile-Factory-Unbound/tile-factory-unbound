package ui
{
  import flash.display.DisplayObjectContainer;
  import flash.ui.Keyboard;
  import lib.Point;
  import lib.ui.ButtonList;
  import lib.ui.Keyboard;
  import lib.ui.Window;

  public class ScrollMenu
  {
    public function ScrollMenu(parent : DisplayObjectContainer,
                               newWindow : Window,
                               newKeyboard : lib.ui.Keyboard,
                               hasMenu : Boolean) : void
    {
      window = newWindow;
      keyboard = newKeyboard;
      dragOrigin = null;
      scrollDir = [];

      window.addDragBeginCommand(dragBegin);
      window.addDragEndCommand(dragEnd);
      window.addDragMoveCommand(dragMove);
      keyboard.addHandler(hotkey);
      keyboard.addUpHandler(upHandler);
    }

    public function cleanup() : void
    {
      keyboard.removeUpHandler(upHandler);
      keyboard.removeHandler(hotkey);
    }

    public function hide() : void
    {
    }

    public function enterFrame() : void
    {
      for each (var dir in scrollDir)
      {
        window.scrollWindow(Dir.walk(new Point(0, 0), dir, INCREMENT));
      }
    }

    function dragBegin(pos : Point) : void
    {
      if (pos != null)
      {
        dragOrigin = window.toRelative(pos);
      }
    }

    function dragEnd(pos : Point) : void
    {
      dragOrigin = null;
    }

    function dragMove(pos : Point) : void
    {
      if (pos != null && dragOrigin != null)
      {
        var current = window.toRelative(pos);
        window.scrollWindow(new Point(dragOrigin.x - current.x,
                                      dragOrigin.y - current.y));
        dragOrigin = current;
      }
    }

    function hotkey(ch : String, code : int) : Boolean
    {
      var used = true;
      if (code == flash.ui.Keyboard.LEFT
          || code == flash.ui.Keyboard.NUMPAD_4)
      {
        addDir(Dir.west);
      }
      else if (code == flash.ui.Keyboard.RIGHT
               || code == flash.ui.Keyboard.NUMPAD_6)
      {
        addDir(Dir.east);
      }
      else if (code == flash.ui.Keyboard.UP
               || code == flash.ui.Keyboard.NUMPAD_8)
      {
        addDir(Dir.north);
      }
      else if (code == flash.ui.Keyboard.DOWN
               || code == flash.ui.Keyboard.NUMPAD_2)
      {
        addDir(Dir.south);
      }
      else
      {
        used = false;
      }
      return used;
    }

    function upHandler(ch : String, code : int) : Boolean
    {
      var used = true;
      if (code == flash.ui.Keyboard.LEFT
          || code == flash.ui.Keyboard.NUMPAD_4)
      {
        removeDir(Dir.west);
      }
      else if (code == flash.ui.Keyboard.RIGHT
               || code == flash.ui.Keyboard.NUMPAD_6)
      {
        removeDir(Dir.east);
      }
      else if (code == flash.ui.Keyboard.UP
               || code == flash.ui.Keyboard.NUMPAD_8)
      {
        removeDir(Dir.north);
      }
      else if (code == flash.ui.Keyboard.DOWN
               || code == flash.ui.Keyboard.NUMPAD_2)
      {
        removeDir(Dir.south);
      }
      else
      {
        used = false;
      }
      return used;
    }

    function addDir(dir : Dir) : void
    {
      var index = scrollDir.indexOf(dir);
      if (index == -1)
      {
        scrollDir.push(dir);
      }
    }

    function removeDir(dir : Dir) : void
    {
      var index = scrollDir.indexOf(dir);
      if (index != -1)
      {
        scrollDir.splice(index, 1);
      }
    }

    var window : lib.ui.Window;
    var keyboard : lib.ui.Keyboard;
    var dragOrigin : Point;
    var scrollDir : Array;

    static var INCREMENT = 15;
  }
}
