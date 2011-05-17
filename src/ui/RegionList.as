package ui
{
  import flash.display.Graphics;
  import flash.utils.ByteArray;

  public class RegionList
  {
    public function RegionList() : void
    {
      cyan = 0;
      magenta = 0;
      yellow = 0;
      absorb = 0;
      stencil = 0;
    }

    public function reset(newCyan : int, newMagenta : int, newYellow : int,
                          newAbsorb : int, newStencil : int) : void
    {
      cyan = newCyan;
      magenta = newMagenta;
      yellow = newYellow;
      absorb = newAbsorb;
      stencil = newStencil;
    }

    public function save(stream : ByteArray) : void
    {
      stream.writeUnsignedInt(cyan);
      stream.writeUnsignedInt(magenta);
      stream.writeUnsignedInt(yellow);
      stream.writeUnsignedInt(absorb);
      stream.writeUnsignedInt(stencil);
    }

    public function copyFrom(other : RegionList) : void
    {
      cyan = other.cyan;
      magenta = other.magenta;
      yellow = other.yellow;
      absorb = other.absorb;
      stencil = other.stencil;
    }

    public function clone() : RegionList
    {
      var result = new RegionList();
      result.copyFrom(this);
      return result;
    }

    public function isStencil(region : int) : Boolean
    {
      return ((stencil >> region) & 0x1) == 1;
    }

    public function getColor(region : int) : int
    {
      return ((((cyan >> region) & 0x1) << 3) |
              (((magenta >> region) & 0x1) << 2) |
              (((yellow >> region) & 0x1) << 1) |
              ((absorb >> region) & 0x1));
    }

    public function paint(newColor : int) : void
    {
      cyan = ((cyan & stencil) | (-((newColor >> 3) & 0x1) & ~stencil));
      magenta = ((magenta & stencil) | (-((newColor >> 2) & 0x1) & ~stencil));
      yellow = ((yellow & stencil) | (-((newColor >> 1) & 0x1) & ~stencil));
      absorb = ((absorb & stencil) | (-(newColor & 0x1) & ~stencil));
    }

    public function addStencil(newMask : int) : void
    {
      stencil = stencil | newMask;
    }

    public function getStencil() : int
    {
      return stencil;
    }

    public function solvent() : void
    {
      stencil = 0;
    }

    public function setColor(region : int, newColor : int) : void
    {
      var mask = ~(0x1 << region);
      cyan = ((cyan & mask) | (((newColor >> 3) & 0x1) << region));
      magenta = ((magenta & mask) | (((newColor >> 2) & 0x1) << region));
      yellow = ((yellow & mask) | (((newColor >> 1) & 0x1) << region));
      absorb = ((absorb & mask) | ((newColor & 0x1) << region));
    }

    public function setStencil(region : int) : void
    {
      stencil = (stencil | (0x1 << region));
    }

    public function getScreenColor(region : int) : int
    {
      var result = 0;
      if (isStencil(region))
      {
        result = stencilColor;
      }
      else
      {
        result = colorMap[getColor(region)];
      }
      return result;
    }

    public function clockwise() : void
    {
      cyan = clockwiseColor(cyan);
      magenta = clockwiseColor(magenta);
      yellow = clockwiseColor(yellow);
      absorb = clockwiseColor(absorb);
      stencil = clockwiseColor(stencil);
    }

    function clockwiseColor(color : int) : int
    {
      return ((color << 8) | ((color >> 24) & 0xff));
    }

    public function counter() : void
    {
      cyan = counterColor(cyan);
      magenta = counterColor(magenta);
      yellow = counterColor(yellow);
      absorb = counterColor(absorb);
      stencil = counterColor(stencil);
    }

    function counterColor(color : int) : int
    {
      return (((color >> 8) & 0x00ffffff) | ((color << 24) & 0xff000000));
    }

    public function drawRegions(surface : Graphics, offset : int,
                                size : int) : void
    {
      surface.clear();
      var i = 0;
      for (; i < RegionList.REGION_COUNT; ++i)
      {
        if (! isStencil(i))
        {
          var color = getScreenColor(i);
          drawNextRegion(surface, i, color, offset, size);
        }
      }
    }

    function drawNextRegion(surface : Graphics, index : int, color : int,
                            offset : int, size : int) : void
    {
      surface.beginFill(color);
      for each (var op in RegionList.regionMap[index])
      {
        var x = scale(op.x, offset, size);
        var y = scale(op.y, offset, size);
        if (op.op == Draw.MOVE)
        {
          surface.moveTo(x, y);
        }
        else if (op.op == Draw.LINE)
        {
          surface.lineTo(x, y);
        }
        else if (op.op == Draw.CURVE)
        {
          var controlX = scale(op.controlX, offset, size);
          var controlY = scale(op.controlY, offset, size);
          surface.curveTo(controlX, controlY, x, y);
        }
      }
      surface.endFill();
    }

    function scale(val : Number, offset : int, size : int) : Number
    {
      return val * size + offset;
    }

    public static function isEqual(left : RegionList,
                                   right : RegionList) : Boolean
    {
      return left.cyan == right.cyan && left.magenta == right.magenta
        && left.yellow == right.yellow && left.absorb == right.absorb
        && left.stencil == right.stencil;
    }

    var cyan : int;
    var magenta : int;
    var yellow : int;
    var absorb : int;
    var stencil : int;

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

    static var stencilColor = 0x9d5148; //0x808000;
    static var colorMap = [0xffffff, // White
                           0x000000, // Black
                           0xffff55, // Light Yellow
                           0xaa5500, // Brown
                           0xff55ff, // Light Magenta
                           0xaa00aa, // Magenta
                           0xff5555, // Light Red
                           0xaa0000, // Red
                           0x55ffff, // Light Cyan
                           0x00aaaa, // Cyan
                           0x55ff55, // Light Green
                           0x00aa00, // Green
                           0x5555ff, // Light Blue
                           0x0000aa, // Blue
                           0xaaaaaa, // Light Grey
                           0x555555]; // Dark Grey

    public static var stencils = [0xffaa0055, 0xffff0000, 0x03000000,
                                  0x0f000000, 0x3f000000];

    public static function setupRegions() : void
    {
      regionMap = new Array(REGION_COUNT);
      var i = 0;
      for (i = 0; i < REGION_COUNT; ++i)
      {
        regionMap[i] = new Array();
      }
      addMove(0, 0, 0);
      addLine(0, 0, 0.2);
      addCurve(0, 0.2, OUTSIDE);
      addLine(0, 0, 0);

      addMove(2, 0, 0.2);
      addLine(2, 0, 0.33);
      addCurve(2, 0.33, OUTSIDE);
      addLine(2, findMiddle(0.2), findMiddle(0.2));
      addCurve(2, 0.2, INSIDE);

      addMove(4, 0, 0.33);
      addLine(4, 0, 0.5);
      addCurve(4, 0.5, OUTSIDE);
      addLine(4, findMiddle(0.33), findMiddle(0.33));
      addCurve(4, 0.33, INSIDE);

      addMove(6, 0, 0.5);
      addLine(6, 0.5, 0.5);
      addLine(6, findMiddle(0.5), findMiddle(0.5));
      addCurve(6, 0.5, INSIDE);
    }

    static function addMove(region : int, x : Number, y : Number) : void
    {
      addAllRotations(region, x, y, Draw.MOVE);
      addAllRotations(region+1, y, x, Draw.MOVE);
    }

    static function addLine(region : int, x : Number, y : Number) : void
    {
      addAllRotations(region, x, y, Draw.LINE);
      addAllRotations(region+1, y, x, Draw.LINE);
    }

    static function findMiddle(radius : Number) : Number
    {
      return radius / Math.SQRT2;
    }

    static var INSIDE = 0;
    static var OUTSIDE = 1;

    static function addCurve(region : int, radius : Number, start : int) : void
    {
      var x = 0;
      var y = radius;
      if (start == OUTSIDE)
      {
        x = findMiddle(radius);
        y = findMiddle(radius);
      }
      var controlX = (Math.SQRT2 - 1) * radius;
      var controlY = radius;
      addAllRotations(region, x, y, Draw.CURVE, controlX, controlY);
      addAllRotations(region + 1, y, x, Draw.CURVE, controlY, controlX);
    }

    static function addAllRotations(region : int, inX : Number, inY : Number,
                                    op : int, ...args) : void
    {
      var x = inX;
      var y = inY;
      var controlX = 0;
      var controlY = 0;
      if (args.length >= 2)
      {
        controlX = args[0];
        controlY = args[1];
      }
      var current = 0;
      var i = 0;
      for (i = 0; i < 4; ++i)
      {
        current = i*8 + region;
        if (args.length < 2)
        {
          regionMap[current].push(new Draw(x, y, op));
        }
        else
        {
          regionMap[current].push(new Draw(x, y, op, controlX, controlY));
        }
        var newX = 1.0 - y;
        var newY = x;
        x = newX;
        y = newY;
        newX = 1.0 - controlY;
        newY = controlX;
        controlX = newX;
        controlY = newY;
      }
    }

    public static var regionMap = null;
    public static var REGION_COUNT = 32;
  }
}
