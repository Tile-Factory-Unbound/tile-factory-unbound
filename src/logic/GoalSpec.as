package logic
{
  import lib.Box;
  import lib.Point;

  public class GoalSpec
  {
    public function GoalSpec(newBounds : Box) : void
    {
      bounds = newBounds.clone();
      pos = new Array();
      color = new Array();
    }

    public var bounds : lib.Box;
    public var pos : Array;
    public var color : Array;
  }
}
