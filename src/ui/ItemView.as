package ui
{
  import flash.filters.GlowFilter;

  import lib.Point;
  import lib.ui.ImageList;
  import logic.Map;
  import logic.Model;

  public class ItemView
  {
    public function ItemView(type : int, newPos : Point,
                             newImages : lib.ui.ImageList) : void
    {
      shrinkage = 0.0;
      angle = 0.0;
      images = newImages;
      item = new ImageRegion(ImageConfig.item);
      images.add(item);
      item.setAlpha(shrinkage);
      item.setScale(shrinkage);
      updateType(type);
      move(newPos);
    }

    public function cleanup() : void
    {
      images.remove(item);
      item.cleanup();
    }

    public function moveDir(dir : Dir, count : int) : void
    {
      Dir.walkMod(pos, dir, count);
      item.setPos(pos);
    }

    public function shrink() : void
    {
      shrinkage -= shrinkStep;
      item.setAlpha(shrinkage);
      item.setScale(shrinkage);
    }

    public function grow() : void
    {
      shrinkage += shrinkStep;
      item.setAlpha(shrinkage);
      item.setScale(shrinkage);
    }

    public function normalSize() : void
    {
      shrinkage = 1.0;
      item.setAlpha(shrinkage);
      item.setScale(shrinkage);
    }

    public function move(newPos : Point) : void
    {
      pos = Map.toCenterPixel(newPos);
      item.setPos(pos);
    }

    public function updateColor(color : TilePixel) : void
    {
      item.setRegion(color);
    }

    public function rotate(delta : Number) : void
    {
      angle += delta;
      item.setRotation(angle);
    }

    public function updateRotation(dir : Dir) : void
    {
      angle = dir.toAngle();
      item.setRotation(dir.toAngle());
    }

    public function updateType(type : int) : void
    {
      item.setFrame(type);
    }

    public function updateSticky(sticky : Boolean) : void
    {
      if (sticky)
      {
        item.setFilter(stickyGlow);
      }
      else
      {
        item.setFilter(null);
      }
    }

    public function getPos() : Point
    {
      return pos;
    }

    var images : lib.ui.ImageList;
    var item : ImageRegion;
    var pos : lib.Point;
    var angle : Number;
    var shrinkage : Number;

    static var stickyGlow = new GlowFilter(0xcc33cc, 0.8, 10, 10, 3, 3);
    static var shrinkStep = 1.0/(Model.HALF_DELAY * 2 - 1);
  }
}
