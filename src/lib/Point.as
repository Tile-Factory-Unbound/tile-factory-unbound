// Point.as
//
// A pair of integers, usually representing a position in a grid or a size.

package lib
{
  public class Point
  {
    public function Point(newX : int,newY : int) : void
    {
      x = newX;
      y = newY;
    }

    public function clone() : Point
    {
      return new Point(x, y);
    }

    public function toString() : String
    {
      return "(" + String(x) + ", " + String(y) + ")";
    }
/*
    public function toPixel() : Point
    {
      return new Point(Lib.cellToPixel(this.x), Lib.cellToPixel(this.y));
    }
*/

    public function plusEquals(right : Point) : void
    {
      x += right.x;
      y += right.y;
    }

    public function save() : *
    {
      return {
        x : this.x,
        y : this.y
      }
    }

    public var x : int;
    public var y : int;

    static public function debug(pos : Point) : String
    {
      if(pos == null)
      {
        return "<NULL>";
      }
      else
      {
        return pos.toString();
      }
    }

    static public function isEqual(left : Point,right : Point) : Boolean
    {
      return (left == null && right == null)
        || (left != null && right != null
            && left.x == right.x && left.y == right.y);
    }

    static public function isAdjacent(left : Point,
                                      right : Point) : Boolean
    {
      var result : Boolean = false;
      if(left == null && right == null)
      {
        result = true;
      }
      else if(left != null && right != null) {
        var x : int = Math.floor(Math.abs(left.x - right.x));
        var y : int = Math.floor(Math.abs(left.y - right.y));
        result = ((x <= 1 && y == 0) || (y <= 1 && x == 0));
      }
      return result;
    }

    static public function isHorizontallyAdjacent(left : Point,
                                                  right : Point) : Boolean
    {
      var result : Boolean = false;
      if(left == null && right == null)
      {
        result = true;
      }
      else if(left != null && right != null)
      {
        var x : int = Math.floor(Math.abs(left.x - right.x));
        var y : int = Math.floor(Math.abs(left.y - right.y));
        result = (y == 0 && x <= 1);
      }
      return result;
    }

    static public function isVerticallyAdjacent(left : Point,
                                                right : Point) : Boolean
    {
      var result : Boolean = false;
      if(left == null && right == null)
      {
        result = true;
      }
      else if(left != null && right != null)
      {
        var x : int = Math.floor(Math.abs(left.x - right.x));
        var y : int = Math.floor(Math.abs(left.y - right.y));
        result = (x == 0 && y <= 1);
      }
      return result;
    }

    static public function save(pos : Point) : *
    {
      return pos.save();
    }

    static public function load(input : *) : Point
    {
      if(input != null)
      {
        return new Point(input.x,input.y);
      }
      else
      {
        return null;
      }
    }
  }
}
