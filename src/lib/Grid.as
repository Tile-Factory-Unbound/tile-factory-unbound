// Grid.as
//
// A two-dimensional array addressable using points.

package lib
{
  public class Grid
  {
    public function Grid(newSize : Point) : void
    {
      size = newSize.clone();
      buffer = new Array(size.x * size.y);
    }

    public function get(pos : Point) : *
    {
      if(pos.x < 0 || pos.x >= size.x || pos.y < 0 || pos.y >= size.y)
      {
        throw new Error("Grid out of bounds: " + pos.toString());
      }
      return buffer[pos.x + pos.y * size.x];
    }

    public function set(pos : Point, val : *) : void
    {
      if(pos.x < 0 || pos.x >= size.x || pos.y < 0 || pos.y >= size.y)
      {
        throw new Error("Grid out of bounds: " + pos.toString());
      }
      buffer[pos.x + pos.y * size.x] = val;
    }

    public function getSize() : Point
    {
      return size;
    }

    var buffer : Array;
    var size : Point;
  }
}
