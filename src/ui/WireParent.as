package ui
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Shape;
  import flash.display.Sprite;
  import flash.geom.Rectangle;

  import lib.Point;

  import lib.ui.Window;

  public class WireParent
  {
    public function WireParent(grandparent : DisplayObjectContainer,
                               newWindow : lib.ui.Window)
    {
      window = newWindow;
      window.addScrollCommand(scroll);
      back = new Shape();
      grandparent.addChild(back);
//      back.graphics.beginFill(0xffffff, 0.3);
//      back.graphics.drawRect(0, 0, window.getSize().x, window.getSize().y);
//      back.graphics.endFill();
      back.visible = false;
//      parent = new Sprite();
//      grandparent.addChild(parent);
      parent = window.getLayer(ImageConfig.wireLayer);
      parent.mouseEnabled = false;
      parent.mouseChildren = false;
      scroll(window.getOffset());
    }

    public function cleanup() : void
    {
//      parent.parent.removeChild(parent);
      back.parent.removeChild(back);
    }

    public function getParent() : DisplayObjectContainer
    {
      return parent;
    }

    public function show() : void
    {
      parent.visible = true;
      back.visible = true;
    }

    public function hide() : void
    {
      parent.visible = false;
      back.visible = false;
    }

    public function startPlay() : void
    {
      var i = 0;
      for (; i < parent.numChildren; ++i)
      {
        parent.getChildAt(i).alpha = 0.2;
      }
      parent.visible = true;
      back.visible = false;
    }

    public function stopPlay() : void
    {
      if (back.visible == false)
      {
        parent.visible = false;
      }
/*
      var i = 0;
      for (; i < parent.numChildren; ++i)
      {
        if (! parent.getChildAt(i).visible)
        {
          parent.getChildAt(i).visible = true;
        }
      }
*/
    }

    public function hideAll() : void
    {
      var i = 0;
      for (; i < parent.numChildren; ++i)
      {
        if (parent.getChildAt(i).alpha > 0.5)
        {
          parent.getChildAt(i).alpha = 0.2;
        }
      }
    }

    public function showAll() : void
    {
      var i = 0;
      for (; i < parent.numChildren; ++i)
      {
        if (parent.getChildAt(i).alpha < 0.5)
        {
          parent.getChildAt(i).alpha = 1;
        }
      }
    }

    function scroll(offset : Point) : Boolean
    {
      var screen = window.getScreen();
      parent.x = screen.x;
      parent.y = screen.y;
      var size = window.getSize();
      parent.scrollRect = new Rectangle(offset.x, offset.y, size.x, size.y);
      return false;
    }

    var parent : Sprite;
    var back : Shape;
    var window : lib.ui.Window;
  }
}
