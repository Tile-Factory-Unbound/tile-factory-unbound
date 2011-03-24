package logic
{
  public class MapTile
  {
    public function MapTile() : void
    {
      part = null;
      item = null;
      itemNext = null;
      track = null;
    }

    public var part : Part;
    public var item : Item;
    public var itemNext : Item;
    public var track : Track;
  }
}
