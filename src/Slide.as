package
{
  import lib.Point;

  public class Slide
  {
    public function Slide(newText : String, newPos : Point,
                          newPixel : Boolean, newAlign : String) : void
    {
      text = newText;
      pos = null;
      if (newPos != null)
      {
        pos = newPos.clone();
      }
      isPixel = newPixel;
      align = newAlign;
    }

    public var text : String;
    public var pos : Point;
    public var isPixel : Boolean;
    public var align : String;
  }
}
