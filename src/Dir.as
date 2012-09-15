// Dir.as
//
// Constants representing directions and utility functions for using
// and converting them.

package
{
  import lib.Box;
  import lib.Point;

  public class Dir
  {
    public static var north = new Dir(0);
    public static var south = new Dir(1);
    public static var east = new Dir(2);
    public static var west = new Dir(3);

    public static var dirs = [north, south, east, west];
    public static var clockwiseDirs = [east, west, south, north];
    public static var counterDirs = [west, east, north, south];
    public static var oppositeDirs = [south, north, west, east];
    public static var deltaPoints = [new Point(0, -1), new Point(0, 1),
                                     new Point(1, 0), new Point(-1, 0)];
    public static var angles = [-90, 90, 0, 180];

    function Dir(newIndex : int) : void
    {
      index = newIndex;
    }

    public static function fromIndex(newIndex : int)
    {
      return dirs[newIndex];
    }

    public function toIndex() : int
    {
      return index;
    }

    public function toAngle() : int
    {
      return angles[index];
    }

    public function clockwise() : Dir
    {
      return clockwiseDirs[index];
    }

    public function counter() : Dir
    {
      return counterDirs[index];
    }

    public function opposite() : Dir
    {
      return oppositeDirs[index];
    }

    public function toDelta() : Point
    {
      return deltaPoints[index];
    }

    var index : int;

    public static function step(pos : Point, dir : Dir) : Point
    {
      return walk(pos, dir, 1);
    }

    public static function walk(pos : Point, dir : Dir, count : int) : Point
    {
      var result = pos.clone();
      walkMod(result, dir, count);
      return result;
    }

    public static function stepMod(pos : Point, dir : Dir) : void
    {
      walkMod(pos, dir, 1);
    }

    public static function walkMod(pos : Point, dir : Dir, count : int) : void
    {
      var delta = deltaPoints[dir.index];
      pos.x += delta.x * count;
      pos.y += delta.y * count;
    }

    // Returns a slice of size count from the dir direction. For
    // example, slice(Direction.NORTH, 5) would return a section as wide
    // as the current one but containing only the northmost 5 rows.
    //
    // The section returned will have count rows/columns regardless of
    // how many were in the original section.
    public static function slice(box : Box, dir : Dir, count : int) : Box
    {
      var result = null;
      if (dir == north)
      {
        result = new Box(box.getOffset(),
                         new Point(box.getLimit().x,
                                   box.getOffset().y + count));
      }
      else if (dir == south)
      {
        result = new Box(new Point(box.getOffset().x,
                                   box.getLimit().y - count),
                         box.getLimit());
      }
      else if (dir == east)
      {
        result = new Box(new Point(box.getLimit().x - count,
                                   box.getOffset().y),
                         box.getLimit());
      }
      else //if (dir == west)
      {
        result = new Box(box.getOffset(),
                         new Point(box.getOffset().x + count,
                                   box.getLimit().y));
      }
      return result;
    }

    // Returns the remainder of the lot after a slice operation would
    // have been done.
    public static function remainder(box : Box, dir : Dir, count : int) : Box
    {
      return slice(box, dir.opposite(), dirSize(box, dir) - count);
    }

    public static function extend(box : Box, dir : Dir, count : int) : Box
    {
      var result = null;
      if (dir == north)
      {
        result = new Box(new Point(box.getOffset().x,
                                   box.getOffset().y - count),
                         box.getLimit());
      }
      else if (dir == south)
      {
        result = new Box(box.getOffset(),
                         new Point(box.getLimit().x,
                                   box.getLimit().y + count));
      }
      else if (dir == east)
      {
        result = new Box(box.getOffset(),
                         new Point(box.getLimit().x + count,
                                   box.getLimit().y));
      }
      else //if (dir == west)
      {
        result = new Box(new Point(box.getOffset().x - count,
                                   box.getOffset().y),
                         box.getLimit());
      }
      return result;
    }

    public static function dirSize(box : Box, dir : Dir) : int
    {
      var result = 0;
      if (dir == north || dir == south)
      {
        result = box.getSize().y;
      }
      else
      {
        result = box.getSize().x;
      }
      return result;
    }
  }
}
