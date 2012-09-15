// Screen.as
//
// A global variable representing screen size. Includes a number of
// utility functions to make it easy to resize or reposition things as
// the screen size changes.

package
{
  import flash.display.DisplayObject;
  import lib.Point;

  public class Screen
  {
    public static var size = new Point(800, 600);

    public static function center(clip : DisplayObject, inSize : Point) : void
    {
      centerX(clip, inSize);
      centerY(clip, inSize);
    }

    public static function centerX(clip : DisplayObject, inSize : Point) : void
    {
      var size = inSize;
      if (size == null)
      {
        size = new Point(clip.width, clip.height);
      }
      clip.x = (clip.stage.stageWidth - size.x)/2;
    }

    public static function centerY(clip : DisplayObject, inSize : Point) : void
    {
      var size = inSize;
      if (size == null)
      {
        size = new Point(clip.width, clip.height);
      }
      clip.y = (clip.stage.stageHeight - size.y)/2;
    }

    public static function bottom(clip : DisplayObject, inSize : Point) : void
    {
      var size = inSize;
      if (size == null)
      {
        size = new Point(clip.width, clip.height);
        clip.y = clip.stage.stageHeight - size.y;
      }
    }

    public static function right(clip : DisplayObject, inSize : Point) : void
    {
      var size = inSize;
      if (size == null)
      {
        size = new Point(clip.width, clip.height);
      }
      clip.x = clip.stage.stageWidth - size.x;
    }

    public static function stretch(clip : DisplayObject) : void
    {
      clip.scaleX = clip.stage.stageWidth/800;
      clip.scaleY = clip.stage.stageHeight/600;
    }

    public static function stretchSquare(clip : DisplayObject,
                                         min : Number, max : Number) : void
    {
      var scale = Math.min(clip.stage.stageWidth/800,
                           clip.stage.stageHeight/600);
      scale = Math.max(scale, min);
      scale = Math.min(scale, max);
      clip.scaleX = scale;
      clip.scaleY = scale;
    }
  }
}
