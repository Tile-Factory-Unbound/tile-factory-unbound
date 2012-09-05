package lib.ui
{
  import flash.display.Stage;
  import flash.events.KeyboardEvent;
  import flash.events.Event;
  import flash.ui.Keyboard;

  public class Keyboard
  {
    public function Keyboard(newStage : flash.display.Stage) : void
    {
      stage = newStage;
      repeat = repeatWait;
      shiftPressed = false;
      hotkeyHandlers = new Array();
      upHandlers = new Array();
      stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
      stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, onKeyUp);
      stage.addEventListener(flash.events.Event.ENTER_FRAME, step);
    }

    public function cleanup() : void
    {
      stage.removeEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
      stage.removeEventListener(flash.events.KeyboardEvent.KEY_UP, onKeyUp);
      stage.removeEventListener(flash.events.Event.ENTER_FRAME, step);
    }

    function onKeyDown(event : flash.events.KeyboardEvent) : void
    {
      if (repeat == repeatWait)
      {
        repeat = 0;
        var ch = String.fromCharCode(event.charCode);
        var code = event.keyCode;

        if (code == flash.ui.Keyboard.SHIFT)
        {
          shiftPressed = true;
        }

        for each (var handler in hotkeyHandlers)
        {
          if (handler(ch, code))
          {
            break;
          }
        }
      }
    }

    function onKeyUp(event : flash.events.KeyboardEvent) : void
    {
      repeat = repeatWait;
      var ch = String.fromCharCode(event.charCode);
      var code = event.keyCode;
      if (event.keyCode == flash.ui.Keyboard.SHIFT)
      {
        shiftPressed = false;
      }
      for each (var handler in upHandlers)
      {
        if (handler(ch, code))
        {
          break;
        }
      }
    }

    function step(event : flash.events.Event) : void
    {
      if (repeat < repeatWait)
      {
        ++repeat;
      }
    }

    public function addHandler(newHandler : Function) : void
    {
      hotkeyHandlers.push(newHandler);
    }

    public function removeHandler(oldHandler : Function) : void
    {
      var index = hotkeyHandlers.indexOf(oldHandler);
      if (index != -1)
      {
        hotkeyHandlers.splice(index, 1);
      }
    }

    public function addUpHandler(newHandler : Function) : void
    {
      upHandlers.push(newHandler);
    }

    public function removeUpHandler(oldHandler : Function) : void
    {
      var index = upHandlers.indexOf(oldHandler);
      if (index != -1)
      {
        upHandlers.splice(index, 1);
      }
    }

    public function clearHandlers() : void
    {
      hotkeyHandlers = new Array();
      upHandlers = new Array();
    }

    public function shift() : Boolean
    {
      return shiftPressed;
    }

    var stage : flash.display.Stage;
    var repeat : int;
    var shiftPressed : Boolean;
    var hotkeyHandlers : Array;
    var upHandlers : Array;

    public static var escapeCode = flash.ui.Keyboard.ESCAPE;
    public static var deleteCode = flash.ui.Keyboard.DELETE;
    public static var backSpaceCode = flash.ui.Keyboard.BACKSPACE;
    public static var enterCode = flash.ui.Keyboard.ENTER;

    static var repeatWait = 0;
  }
}
