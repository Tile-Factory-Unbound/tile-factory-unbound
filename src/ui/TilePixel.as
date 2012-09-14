// Internal representation for the state of all pixels on a tile.

package ui
{
  import flash.display.BitmapData;
  import flash.utils.ByteArray;

  public class TilePixel
  {

    public function TilePixel() : void
    {
      cyan = new TileBit();
      magenta = new TileBit();
      yellow = new TileBit();
      absorb = new TileBit();
      stencil = new TileBit();
    }

    public function reset(newCyan : TileBit, newMagenta : TileBit,
                          newYellow : TileBit, newAbsorb : TileBit,
                          newStencil : TileBit) : void
    {
      cyan.copyFrom(newCyan);
      magenta.copyFrom(newMagenta);
      yellow.copyFrom(newYellow);
      absorb.copyFrom(newAbsorb);
      stencil.copyFrom(newStencil);
    }

    public function save(stream : ByteArray) : void
    {
      cyan.save(stream);
      magenta.save(stream);
      yellow.save(stream);
      absorb.save(stream);
      stencil.save(stream);
    }

    public function saveStencil(stream : ByteArray) : void
    {
      stencil.save(stream);
    }

    public function load(stream : ByteArray) : void
    {
      cyan.load(stream);
      magenta.load(stream);
      yellow.load(stream);
      absorb.load(stream);
      stencil.load(stream);
    }

    public function loadStencil(stream : ByteArray) : void
    {
      stencil.load(stream);
    }

    public function copyFrom(other : TilePixel) : void
    {
      reset(other.cyan, other.magenta, other.yellow, other.absorb,
            other.stencil);
    }

    public function convertFrom(other : RegionList) : void
    {
      cyan.clear();
      magenta.clear();
      yellow.clear();
      absorb.clear();
      stencil.clear();
      var i = 0;
      for (; i < RegionList.REGION_COUNT; ++i)
      {
        var color = other.getColor(i);
        paintMask(color, regionToMask[i]);
        if (other.isStencil(i))
        {
          addStencil(regionToBit[i]);
        }
      }
    }

    public function fromStamp(stamp : Array) : void
    {
      cyan.clear();
      magenta.clear();
      yellow.clear();
      absorb.clear();
      stencil.clear();
      addStencil(stampToBit(stamp));
    }

    public function clone() : TilePixel
    {
      var result = new TilePixel();
      result.copyFrom(this);
      return result;
    }

    public function isStencil(index : int) : Boolean
    {
      return (stencil.get(index) == 1);
    }

    public function getColor(index : int) : int
    {
      return ((cyan.get(index) << 3) |
              (magenta.get(index) << 2) |
              (yellow.get(index) << 1) |
              absorb.get(index));
    }

    public function paint(newColor : int) : void
    {
      paintMask(newColor, stencil);
    }

    private function paintMask(newColor : int, mask : TileBit) : void
    {
      cyan.paint(newColor >> 3, mask);
      magenta.paint(newColor >> 2, mask);
      yellow.paint(newColor >> 1, mask);
      absorb.paint(newColor, mask);
    }

    public function addStencil(newMask : TileBit) : void
    {
      stencil.or(newMask);
    }

    public function getStencil() : TileBit
    {
      return stencil;
    }

    public function toggleStencil(x : int, y : int) : void
    {
      var index = x + y*TileBit.dim;
      stencil.set(index, (~stencil.get(index)) & 0x1);
    }

    public function solvent() : void
    {
      stencil.clear();
    }

    public function setColor(index : int, newColor : int) : void
    {
      cyan.set(index, newColor >> 3);
      magenta.set(index, newColor >> 2);
      yellow.set(index, newColor >> 1);
      absorb.set(index, newColor);
    }

    public function setStencil(index : int) : void
    {
      stencil.set(index, 0x1);
    }

    public function getScreenColor(index : int, isTile : Boolean) : int
    {
      var result : int = 0;
      if (isStencil(index))
      {
        result = stencilColor;
      }
      else if (! isTile)
      {
        result = 0x00000000;
      }
      else
      {
        result = colorMap[getColor(index)];
      }
      return result;
    }

    public function clockwise() : void
    {
      cyan.clockwise();
      magenta.clockwise();
      yellow.clockwise();
      absorb.clockwise();
      stencil.clockwise();
    }

    public function counter() : void
    {
      cyan.counter();
      magenta.counter();
      yellow.counter();
      absorb.counter();
      stencil.counter();
    }

    public function flip(isVertical : Boolean) : void
    {
      stencil.flip(isVertical);
    }

    public function invert() : void
    {
      stencil.invert();
    }

    public function drawRegions(surface : BitmapData, isTile : Boolean) : void
    {
      surface.lock();
      var y = 0;
      for (; y < TileBit.dim; ++y)
      {
        var x = 0;
        for (; x < TileBit.dim; ++x)
        {
          var color : int = getScreenColor(x + y*TileBit.dim, isTile);
          surface.setPixel32(x, y, color);
        }
      }
      surface.unlock();
    }

    public static function isEqual(left : TilePixel,
                                   right : TilePixel) : Boolean
    {
      return left.cyan.isEqual(right.cyan)
        && left.magenta.isEqual(right.magenta)
        && left.yellow.isEqual(right.yellow)
        && left.absorb.isEqual(right.absorb)
        && left.stencil.isEqual(right.stencil);
    }

    var cyan : TileBit;
    var magenta : TileBit;
    var yellow : TileBit;
    var absorb : TileBit;
    var stencil : TileBit;

    public static function stampToBit(stamp : Array) : TileBit
    {
      var result = new TileBit();
      var index = 0;
      for each (var row in stamp)
      {
        var i = 0;
        for (; i < row.length; ++i)
        {
          var bit = 0;
          if (row.substr(i, 1) == "1")
          {
            bit = 1;
          }
          result.set(index, bit);
          index = index + 1;
        }
      }
      return result;
    }

    public static function mix(left : int, right : int) : int
    {
      var result = 0;
      if ((left == WHITE && right == BLACK)
          || (left == BLACK && right == WHITE))
      {
        result = 0xf;
      }
      else if (left == WHITE && right != WHITE)
      {
        result = right & 0xe;
      }
      else if (left != WHITE && right == WHITE)
      {
        result = left & 0xe;
      }
      else
      {
        result = left | right;
      }
      return result;
    }

    static var WHITE = 0;
    static var BLACK = 0x1;

    static var stencilColor : uint = 0xffeeddcc;//0x9d5148;
    static var colorMap = [0xffffffff, // White
                           0xff000000, // Black
                           0xffffff55, // Light Yellow
                           0xffaa5500, // Brown
                           0xffff55ff, // Light Magenta
                           0xffaa00aa, // Magenta
                           0xffff5555, // Light Red
                           0xffaa0000, // Red
                           0xff55ffff, // Light Cyan
                           0xff00aaaa, // Cyan
                           0xff55ff55, // Light Green
                           0xff00aa00, // Green
                           0xff5555ff, // Light Blue
                           0xff0000aa, // Blue
                           0xffaaaaaa, // Light Grey
                           0xff555555]; // Dark Grey

    static var regionToBit = new Array(RegionList.REGION_COUNT);
    static var regionToMask = new Array(RegionList.REGION_COUNT);

    public static function setupRegions() : void
    {
      var quad = 0;
      for (; quad < 4; ++ quad)
      {
        var reg = 0;
        for (; reg < 8; ++reg)
        {
          var bit = setupBit(reg);
          var rot = 0;
          for (; rot < quad; ++rot)
          {
            bit.clockwise();
          }
          regionToBit[quad*8 + reg] = bit;
          var mask = bit.clone();
          mask.invert();
          regionToMask[quad*8 + reg] = mask;
        }
      }
    }

    static function setupBit(reg : int) : TileBit
    {
      var region = String(reg);
      var bit = new TileBit();
      var y = 0;
      for (; y < 15; ++y)
      {
        var x = 0;
        for (; x < 15; ++x)
        {
          var str = pixelRegionText.charAt(x + y*15);
          if (str == region)
          {
            bit.setPos(x, y, 0x1);
          }
        }
      }
      return bit;
    }

    static var pixelRegionText =
    "011111333355555" +
    "001111333355555" +
    "000113333355555" +
    "000013333555557" +
    "000023333555557" +
    "002222335555557" +
    "222222255555577" +
    "222222445555577" +
    "222224444555777" +
    "222444444455777" +
    "444444444447777" +
    "444444444466777" +
    "444444446666677" +
    "444444666666667" +
    "444666666666666";
  }
}
