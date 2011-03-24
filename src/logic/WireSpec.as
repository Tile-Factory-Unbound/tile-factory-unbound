package logic
{
  import lib.Point;

  public class WireSpec
  {
    public function WireSpec(newSource : Point, newDest : Point) : void
    {
      source = newSource.clone();
      dest = newDest.clone();
    }

    public var source : lib.Point;
    public var dest : lib.Point;
  }
}
