package ui
{
  import lib.Point;
  import lib.ui.ImageList;
  import logic.Map;

  public class GoalTileView
  {
    public function GoalTileView(pos : Point,
                                 newImages : lib.ui.ImageList) : void
    {
      images = newImages;
      tile = new ImageRegion(ImageConfig.goalTile);
      images.add(tile);
      updatePos(pos);
    }

    public function cleanup() : void
    {
      images.remove(tile);
      tile.cleanup();
    }

    public function updatePos(pos : Point) : void
    {
      tile.setPos(Map.toCenterPixel(pos));
    }

    public function updateColor(color : TilePixel) : void
    {
      tile.setRegion(color);
    }

    var images : lib.ui.ImageList;
    var tile : ImageRegion;
  }
}
