package lib.ui
{
  import flash.display.MovieClip;
  import flash.events.MouseEvent;
  import flash.filters.GlowFilter;

  public class ButtonList
  {
    public function ButtonList(newButtonList : Array) : void
    {
      buttonList = newButtonList;
      buttonState = new Array();
      clickAction = null;
      overAction = null;
      outAction = null;
      var i : int = 0;
      for (; i < buttonList.length; ++i)
      {
        var button : MovieClip = buttonList[i];
        button.mouseChildren = false;
        button.addEventListener(MouseEvent.CLICK, buttonClick);
        button.addEventListener(MouseEvent.MOUSE_OVER, buttonOver);
        button.addEventListener(MouseEvent.MOUSE_OUT, buttonOut);
        button.stop();
        buttonState.push(false);
      }
    }

    public function setActions(newClickAction : Function,
                               newOverAction : Function,
                               newOutAction : Function) : void
    {
      clickAction = newClickAction;
      overAction = newOverAction;
      outAction = newOutAction;
    }

    public function cleanup() : void
    {
      var i : int = 0;
      for (; i < buttonList.length; ++i)
      {
        var button : MovieClip = buttonList[i];
        button.removeEventListener(MouseEvent.CLICK,this.buttonClick);
        button.removeEventListener(MouseEvent.MOUSE_OVER,this.buttonOver);
        button.removeEventListener(MouseEvent.MOUSE_OUT,this.buttonOut);
      }
    }

    public function get(index : int) : flash.display.MovieClip
    {
      return buttonList[index];
    }

    function buttonClick(event : MouseEvent) : void
    {
      var index : int = getButtonIndex(event);
      if (index != -1)
      {
        if (clickAction != null)
        {
          clickAction(index);
        }
      }
    }

    function buttonOver(event : MouseEvent) : void
    {
      var index : int = getButtonIndex(event);
      if (index != -1
          && ! buttonState[index])
      {
        buttonState[index] = true;
        if (overAction != null)
        {
          overAction(index);
        }
      }
    }

    function buttonOut(event : MouseEvent) : void
    {
      var index : int = getButtonIndex(event);
      if (index != -1
          && buttonState[index])
      {
        buttonState[index] = false;
        if (outAction != null)
        {
          outAction(index);
        }
      }
    }

    function getButtonIndex(event : MouseEvent) : int
    {
      var index : int = -1;
      var i : int = 0;
      for (; i < buttonList.length; ++i)
      {
        if (buttonList[i] == event.target)
        {
          index = i;
          break;
        }
      }
      return index;
    }

    public function frameOver(index : int) : void
    {
      buttonList[index].gotoAndStop(OVER);
    }

    public function frameOut(index : int) : void
    {
      buttonList[index].gotoAndStop(NORMAL);
    }

    public function glowOver(index : int) : void
    {
      var filter = new GlowFilter(0xffffff, 0.5, 10, 10, 5, 3);
      var filterList = buttonList[index].filters;
      if (filterList == null)
      {
        filterList = new Array();
      }
      filterList.push(filter);
      buttonList[index].filters = filterList;
    }

    public function glowOut(index : int) : void
    {
      var filterList = buttonList[index].filters;
      if (filterList == null)
      {
        filterList = new Array();
      }
      if (filterList.length > 0)
      {
        filterList.pop();
      }
      buttonList[index].filters = filterList;
    }

    var buttonList : Array;
    var buttonState : Array;
    var clickAction : Function;
    var overAction : Function;
    var outAction : Function;

    static var NORMAL : int = 1;
    static var OVER : int = 2;
  }
}
