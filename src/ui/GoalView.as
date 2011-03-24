package ui
{
  import lib.Box;
  import lib.Point;
  import lib.ui.ImageList;
  import lib.ui.ImageText;
  import lib.ui.ImageType;
  import logic.Map;

  public class GoalView
  {
    public function GoalView(bounds : Box, newImages : lib.ui.ImageList) : void
    {
      images = newImages;
      text = new ImageText(ImageConfig.goalText);
      images.add(text);
      background = null;
      updateBounds(bounds, boxColorNormal);
    }

    public function cleanup() : void
    {
      images.remove(text);
      text.cleanup();
      if (background != null)
      {
        images.remove(background);
        background.cleanup();
      }
    }

    public function updateCount(count : int) : void
    {
      if (count <= 0)
      {
        text.setVisible(false);
      }
      else
      {
        text.setVisible(true);
        text.setText(String(count));
      }
    }

    public function updateBounds(bounds : Box, color : int) : void
    {
      if (background != null)
      {
        images.remove(background);
        background.cleanup();
        background = null;
      }
      text.setPos(Map.toCenterPixel(bounds.getOffset()));
      var config = new ImageType("EmptyClip", ImageConfig.goalLayer,
                                 Map.toPixel(bounds.getSize()));
      background = new ImageBox(config);
      images.add(background);
      background.setPos(Map.toCenterPixelBox(bounds));
      var size = Map.toPixel(bounds.getSize());
      size.x += Map.halfTileSize;
      size.y += Map.halfTileSize;
      background.setBox(size, color, boxAlpha);
    }

    public function makeTileSprite(pos : Point) : GoalTileView
    {
      return new GoalTileView(pos, images);
    }

    var images : lib.ui.ImageList;
    var text : lib.ui.ImageText;
    var background : ImageBox;

    public static var boxColorNormal = 0x777777;
    public static var boxColorSelected = 0x000000;
    static var boxAlpha = 0.2;
  }
}
