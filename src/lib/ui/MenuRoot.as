package lib.ui
{
  import flash.display.MovieClip;
  import flash.display.DisplayObjectContainer;

  public class MenuRoot
  {
    public function MenuRoot(newParent : DisplayObjectContainer,
                             newClip : MovieClip,
                             rightEdge : Boolean, bottomEdge : Boolean) : void
    {
      nextMenu = MenuList.CURRENT_MENU;
      parent = newParent;
      rootClip = newClip;
      parent.addChild(rootClip);
      if (rightEdge)
      {
        rootClip.x = parent.stage.stageWidth;
      }
      if (bottomEdge)
      {
        rootClip.y = parent.stage.stageHeight;
      }
      hide();
    }

    public function cleanup() : void
    {
      rootClip.parent.removeChild(rootClip);
    }

    public function resize() : void
    {
    }

    public function show() : void
    {
      rootClip.visible = true;
    }

    public function hide() : void
    {
      rootClip.visible = false;
    }

    public function getNextMenu() : int
    {
      var result = nextMenu;
      nextMenu = MenuList.CURRENT_MENU;
      return result;
    }

    var parent : DisplayObjectContainer;
    protected var rootClip : MovieClip;
    protected var nextMenu : int;
  }
}
