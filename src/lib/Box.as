// Box.as
//
// A box is a rectangular axis-aligned rectangle of integer
// dimensions. Usually,  it is a region on the map.

package lib
{
  public class Box
  {
    public function Box(newOffset : Point, newLimit : Point) : void
    {
      offset = new Point(Math.floor(Math.min(newOffset.x, newLimit.x)),
                         Math.floor(Math.min(newOffset.y, newLimit.y)));
      limit = new Point(Math.floor(Math.max(newOffset.x, newLimit.x)),
                        Math.floor(Math.max(newOffset.y, newLimit.y)));
      size = new Point(limit.x - offset.x, limit.y - offset.y);
    }

    public static function createSize(newOffset : Point, newSize : Point) : Box
    {
      return new Box(newOffset, new Point(newOffset.x + newSize.x,
                                          newOffset.y + newSize.y));
    }

    public function clone() : Box
    {
      return new Box(offset, limit);
    }

    public function getOffset() : Point
    {
      return offset;
    }

    public function getLimit() : Point
    {
      return limit;
    }

    public function getSize() : Point
    {
      return size;
    }

    public function moveTo(newOffset : Point) : void
    {
      offset = newOffset.clone();
      limit = new Point(offset.x + size.x, offset.y + size.y);
    }

    public function contains(pos : Point) : Boolean
    {
      return (pos.x >= offset.x && pos.x < limit.x
              && pos.y >= offset.y && pos.y < limit.y);
    }

    public function containsBox(other : Box) : Boolean
    {
      return (other.offset.x >= offset.x && other.offset.y >= offset.y
              && other.limit.x <= limit.x && other.limit.y <= limit.y);
    }

    public function foreach(func : Function, thisObj : *, ...extraArgs) : void
    {
      var pos : Point = new Point(0, 0);
      var args : Array = [pos];
      args = args.concat(extraArgs);
      for (pos.y = offset.y; pos.y < limit.y; ++pos.y)
      {
        for (pos.x = offset.x; pos.x < limit.x; ++pos.x)
        {
          func.apply(thisObj, args);
        }
      }
    }

    public function isAll(func : Function, thisObj : *, ...extraArgs) : Boolean
    {
      var result = true;
      var pos : Point = new Point(0, 0);
      var args : Array = [pos];
      args = args.concat(extraArgs);
      for (pos.y = offset.y; pos.y < limit.y; ++pos.y)
      {
        for (pos.x = offset.x; pos.x < limit.x; ++pos.x)
        {
          result = result && func.apply(thisObj, args);
        }
      }
      return result;
    }

    public function isSome(func : Function, thisObj : *, ...extraArgs) : Boolean
    {
      var result = false;
      var pos : Point = new Point(0, 0);
      var args : Array = [pos];
      args = args.concat(extraArgs);
      for (pos.y = offset.y; pos.y < limit.y; ++pos.y)
      {
        for (pos.x = offset.x; pos.x < limit.x; ++pos.x)
        {
          result = result || func.apply(thisObj, args);
          if (result)
          {
            break;
          }
        }
        if (result)
        {
          break;
        }
      }
      return result;
    }

    public function search(func : Function, thisObj : *, ...extraArgs) : *
    {
      var result = null;
      var pos : Point = new Point(0, 0);
      var args : Array = [pos];
      args = args.concat(extraArgs);
      for (pos.y = offset.y; pos.y < limit.y; ++pos.y)
      {
        for (pos.x = offset.x; pos.x < limit.x; ++pos.x)
        {
          result = func.apply(thisObj, args);
          if (result != null)
          {
            break;
          }
        }
        if (result != null)
        {
          break;
        }
      }
      return result;
    }


    public function foreachBorder(func : Function, thisObj : *,
                                  ...extraArgs) : void
    {
      var pos : Point = new Point(0, 0);
      var args : Array = [pos];
      args = args.concat(extraArgs);
      for (pos.y = offset.y; pos.y < limit.y; ++pos.y)
      {
        pos.x = offset.x;
        func.apply(thisObj, args);
        pos.x = limit.x - 1;
        func.apply(thisObj, args);
      }
      for (pos.x = offset.x + 1; pos.x < limit.x - 1; ++pos.x)
      {
        pos.y = offset.y;
        func.apply(thisObj, args);
        pos.y = limit.y - 1;
        func.apply(thisObj, args);
      }
    }

    var offset : Point;
    var limit : Point;
    var size : Point;
  }
}
