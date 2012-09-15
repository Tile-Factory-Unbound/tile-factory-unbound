// Slide.as
//
// A struct for storing a 'slide' (think slide deck) for the tutorial.

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

    // Text to display to user
    public var text : String;
    // Position to point arrow
    public var pos : Point;
    // Is the position an absolute screen position? Or is it a map position?
    // TODO: How should this work on screen resize?
    public var isPixel : Boolean;
    // TODO: What is this for?
    public var align : String;
  }
}
