package logic
{
  import lib.Grid;
  import lib.Point;
  import lib.Box;

  public class Map
  {
    public static var tileSize : int = 32;
    public static var halfTileSize : int = 16;

    public static function toTile(pos : lib.Point) : lib.Point
    {
      return new lib.Point(Math.floor(pos.x / tileSize),
                           Math.floor(pos.y / tileSize));
    }

    public static function toPixel(pos : lib.Point) : lib.Point
    {
      return new lib.Point(pos.x * tileSize, pos.y * tileSize);
    }

    public static function toCenterPixel(pos : lib.Point) : lib.Point
    {
      return new lib.Point(pos.x * tileSize + halfTileSize,
                           pos.y * tileSize + halfTileSize);
    }

    public static function toCenterPixelBox(box : lib.Box) : lib.Point
    {
      var offset = box.getOffset();
      var size = box.getSize();
      return new lib.Point(offset.x * tileSize + size.x * halfTileSize,
                           offset.y * tileSize + size.y * halfTileSize);
    }

    public function Map(size : Point) : void
    {
      tiles = new lib.Grid(maxSize);
      bounds = lib.Box.createSize(new lib.Point(0, 0), size);
      var maxBounds = lib.Box.createSize(new lib.Point(0, 0), maxSize);
      maxBounds.foreach(initTile, this);
    }

    function initTile(pos : Point) : void
    {
      setTile(pos, new MapTile());
    }

    public function getTile(pos : Point) : MapTile
    {
      var result = null;
      if (insideMap(pos))
      {
        result = tiles.get(pos);
      }
      return result;
    }

    public function setTile(pos : Point, tile : MapTile) : void
    {
      tiles.set(pos, tile);
    }

    public function changeSize(dir : Dir, delta : int) : Boolean
    {
      var result = false;
      var newSize = Dir.walk(bounds.getSize(), dir, delta);
      if (newSize.x >= minSize.x && newSize.x <= maxSize.x
          && newSize.y >= minSize.y && newSize.y <= maxSize.y)
      {
        if (delta < 0)
        {
          var old = Dir.slice(bounds, dir, -delta);
          var newBounds = Dir.remainder(bounds, dir, -delta);
          var ok = true;
          var pos : Point = new Point(0, 0);
          for (pos.y = old.getOffset().y; pos.y < old.getLimit().y; ++pos.y)
          {
            for (pos.x = old.getOffset().x; pos.x < old.getLimit().x; ++pos.x)
            {
              if (getTile(pos).part != null)
              {
                ok = false;
                break;
              }
            }
          }
          if (ok)
          {
            bounds = newBounds;
            result = true;
          }
        }
        else
        {
          bounds = Dir.extend(bounds, dir, delta);
          result = true;
        }
      }
      return result;
    }

    public function getSize() : Point
    {
      return bounds.getSize();
    }

    public function insideMap(pos : lib.Point) : Boolean
    {
      return bounds.contains(pos);
    }

    public function insideMapBox(box : lib.Box) : Boolean
    {
      return bounds.containsBox(box);
    }

    public function canPlacePart(pos : lib.Point) : Boolean
    {
      return insideMap(pos) && tiles.get(pos).part == null;
    }

    public function canPlaceItem(pos : lib.Point) : Boolean
    {
      return insideMap(pos) && tiles.get(pos).item == null
        && tiles.get(pos).itemNext == null;
    }

    public function canStartWire(pos : lib.Point) : Boolean
    {
      return insideMap(pos) && tiles.get(pos).part != null
        && tiles.get(pos).part.canStartWire();
    }

    public function canEndWire(source : lib.Point, pos : lib.Point) : Boolean
    {
      return ! Point.isEqual(source, pos)&& insideMap(pos)
        && tiles.get(pos).part != null
        && tiles.get(pos).part.canEndWire(source, this);
    }

    public function forEachInLine(pos : Point, dir : Dir, f : Function,
                                  thisObj : *, ...extraArgs) : void
    {
      var current : Point = pos.clone();
      var next : Point = pos.clone();
      Dir.stepMod(next, dir);
      var args : Array = [current];
      args = args.concat(extraArgs);
      var done = false;
      var isFirst = true;
      while (!done && insideMap(next))
      {
        var currentCell = getTile(current);
        var nextCell = getTile(next);
        var currentClear = currentCell.part == null
          || ! currentCell.part.isConveyer() || isFirst;
        var nextClear = nextCell.part == null
          || ! nextCell.part.isBarrier();
        done = ! currentClear || ! nextClear;
        if (!done)
        {
          f.apply(thisObj, args);
          Dir.stepMod(current, dir);
          Dir.stepMod(next, dir);
        }
        isFirst = false;
      }
    }

    public function retrackAll(pos : Point) : void
    {
      var current = new Point(0, 0);
      var i = 0;
      current.y = pos.y;
      for (i = 0; i < bounds.getLimit().x; ++i)
      {
        current.x = i;
        retrack(current);
      }
      current.x = pos.x;
      for (i = 0; i < bounds.getLimit().y; ++i)
      {
        current.y = i;
        retrack(current);
      }
    }

    function retrack(pos : Point) : void
    {
      if (getTile(pos).part != null)
      {
        getTile(pos).part.addAllTracks();
      }
    }

    public function untrackAll(pos : Point) : void
    {
      var current = new Point(0, 0);
      var i = 0;
      current.y = pos.y;
      for (i = 0; i < bounds.getLimit().x; ++i)
      {
        current.x = i;
        untrack(current);
      }
      current.x = pos.x;
      for (i = 0; i < bounds.getLimit().y; ++i)
      {
        current.y = i;
        untrack(current);
      }
    }

    function untrack(pos : Point) : void
    {
      if (getTile(pos).part != null)
      {
        getTile(pos).part.removeAllTracks();
      }
    }

    var tiles : lib.Grid;
    var bounds : lib.Box;

    public static var minSize = new Point(7, 7);
    public static var maxSize = new Point(60, 60);
  }
}
