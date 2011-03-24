package ui
{
  import lib.Point;
  import lib.ui.Image;
  import lib.ui.ImageType;
  import lib.ui.Window;

  import logic.Map;

  public class ImageBox extends Image
  {
    public function ImageBox(newType : ImageType) : void
    {
      boxSize = null;
      boxColor = 0;
      boxAlpha = 1.0;
      super(newType);
    }

    public function setBox(newSize : Point, newColor : int,
                           newAlpha : Number) : void
    {
      if (newSize == null)
      {
        boxSize = newSize;
      }
      else
      {
        boxSize = newSize.clone();
        boxColor = newColor;
        boxAlpha = newAlpha;
      }
      boxChanged = true;
    }

    override public function update(window : Window) : void
    {
      super.update(window);
      updateBox();
    }

    function updateBox() : void
    {
      if (boxChanged && image != null)
      {
        image.graphics.clear();
        image.graphics.beginFill(boxColor, boxAlpha);
        image.graphics.drawRect(-(boxSize.x/2), -(boxSize.y/2),
                                boxSize.x, boxSize.y);
        image.graphics.endFill();
      }
      boxChanged = false;
    }

    override protected function invalidate() : void
    {
      super.invalidate();
      boxChanged = true;
    }

    var boxSize : Point;
    var boxColor : int;
    var boxAlpha : Number;
    var boxChanged : Boolean;
  }
}
