package lib.ui
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import lib.Point;

  public class WindowBorder
  {
    public function WindowBorder() : void
    {
    }

    public function init(parent : DisplayObjectContainer) : void
    {
      clip = new Sprite();
      parent.addChild(clip);
      clip.cacheAsBitmap = true;
    }

    public function cleanup() : void
    {
      clip.parent.removeChild(clip);
    }

    public function update(offset : Point, screen : Point, size : Point,
                           windowSize : Point) : void
    {
      clip.graphics.clear();
      clip.graphics.lineStyle(10, 0x000000);
      clip.graphics.drawRect(0, 0,
                             size.x, size.y);
    }

    protected var clip : Sprite;
  }
}
