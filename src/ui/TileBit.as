// Internal representation for state of a single bit over the whole
// tile (c, m, y, a, or stencil).

package ui
{
  import logic.Map;
  import flash.utils.ByteArray;

  public class TileBit
  {
    public function TileBit() : void
    {
      bits = new Array(size);
      clear();
    }

    public function copyFrom(newTile : TileBit) : void
    {
      var i : int = 0;
      for (; i < size; ++i)
      {
        bits[i] = newTile.bits[i];
      }
    }

    public function clone() : TileBit
    {
      var result : TileBit = new TileBit();
      result.copyFrom(this);
      return result;
    }

    public function save(stream : ByteArray) : void
    {
      var i : int = 0;
      for (; i < size; ++i)
      {
        stream.writeInt(bits[i]);
      }
    }

    public function load(stream : ByteArray) : void
    {
      var i : int = 0;
      for (; i < size; ++i)
      {
        bits[i] = stream.readInt();
      }
    }

    public function get(index : int) : int
    {
      var major : int = Math.min(index/32);
      var minor : int = index % 32;
      return (bits[major] >> minor) & 0x1;
    }

    public function getPos(x : int, y : int) : int
    {
      return get(x + y*dim);
    }

    public function set(index : int, bit : int) : void
    {
      var major : int = Math.min(index/32);
      var minor : int = index % 32;
      var mask : int = ~(0x1 << minor);
      bits[major] = ((bits[major] & mask) | ((bit & 0x1) << minor));
    }

    public function setPos(x : int, y : int, bit : int) : void
    {
      set(x + y*dim, bit);
    }

    public function paint(bit : int, stencil : TileBit) : void
    {
      var i : int = 0;
      for (; i < size; ++i)
      {
        bits[i] = ((bits[i] & stencil.bits[i]) |
                   (-(bit & 0x1) & ~stencil.bits[i]));
      }
    }

    public function or(other : TileBit) : void
    {
      var i : int = 0;
      for (; i < size; ++i)
      {
        bits[i] = bits[i] | other.bits[i];
      }
    }

    public function invert() : void
    {
      var i : int = 0;
      for (; i < size; ++i)
      {
        bits[i] = ~bits[i];
      }
    }

    public function clear() : void
    {
      var i : int = 0;
      for (; i < size; ++i)
      {
        bits[i] = int(0);
      }
    }

    public function clockwise() : void
    {
      var base : TileBit = clone();
      var y : int = 0;
      for (; y < dim; ++y)
      {
        var x : int = 0;
        for (; x < dim; ++x)
        {
          setPos(dim-y-1, x, base.getPos(x, y));
        }
      }
    }

    public function counter() : void
    {
      var base : TileBit = clone();
      var y : int = 0;
      for (; y < dim; ++y)
      {
        var x : int = 0;
        for (; x < dim; ++x)
        {
          setPos(y, dim-x-1, base.getPos(x, y));
        }
      }
    }

    public function flip(isVertical : Boolean) : void
    {
      var base : TileBit = clone();
      var y : int = 0;
      for (; y < dim; ++y)
      {
        var x : int = 0;
        for (; x < dim; ++x)
        {
          if (isVertical)
          {
            setPos(x, dim-y-1, base.getPos(x, y));
          }
          else
          {
            setPos(dim-x-1, y, base.getPos(x, y));
          }
        }
      }
    }

    public function isEqual(other : TileBit) : Boolean
    {
      var result : Boolean = true;
      var i : int = 0;
      for (; i < size && result; ++i)
      {
        if (i == size - 1)
        {
          var mask = ((0x1 << (bitCount % 32)) >> 1) - 1;
//          bits[size - 1] = bits[size-1] & mask;
          result = ((bits[i] & mask) == (other.bits[i] & mask));
        }
        else
        {
          result = (bits[i] == other.bits[i]);
        }
      }
      return result;
    }

    var bits : Array;
    public static var dim = Map.tileSize - 2;
    static var bitCount = dim * dim;
    static var size = Math.ceil(bitCount/32);
  }
}
