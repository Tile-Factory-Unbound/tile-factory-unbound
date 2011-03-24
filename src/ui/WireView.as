package ui
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Graphics;
  import flash.display.Shape;

  import lib.Point;

  import logic.Map;

  public class WireView
  {
    public function WireView(parent : DisplayObjectContainer,
                             source : Point, dest : Point)
    {
      var sourcePixel = Map.toCenterPixel(source);
      var a = (sourcePixel.x & 0x7f) + 0x80;
      var b = (sourcePixel.y & 0x7f) + 0x80;
      var c = ((sourcePixel.x ^ sourcePixel.y) & 0x7f) + 0x80;
/*
      wireColor = int(Math.random()*96 + 160)
        | (int(Math.random()*96 + 160) << 8)
        | (int(Math.random()*96 + 160) << 16);
*/
      wireColor = a | (b << 8) | (c << 16);
      wire = new Shape();
      parent.addChild(wire);
      update(source, dest);
    }

    public function cleanup() : void
    {
      wire.parent.removeChild(wire);
    }

    public function show() : void
    {
      wire.alpha = 1;
/*
      if (! wire.visible)
      {
        wire.visible = true;
      }
*/
    }

    public function hide() : void
    {
      wire.alpha = 0.2;
//      wire.visible = true;
//      wire.visible = false;
    }

    public function update(source : Point, dest : Point) : void
    {
      wire.graphics.clear();
      drawWire(wire.graphics, Map.toCenterPixel(source),
               Map.toCenterPixel(dest), wireColor);
    }

    var wire : Shape;
    var wireColor : int;

    public static function drawWire(surface : Graphics, sourceCenter : Point,
                                    destCenter : Point, color : int) : void
    {
      var angle = Math.atan2(destCenter.y - sourceCenter.y,
                             destCenter.x - sourceCenter.x);
      var perp = angle + Math.PI/2;
      var deltaX = Math.floor(Math.cos(perp)*destLength);
      var deltaY = Math.floor(Math.sin(perp)*destLength);
      deltaX = Math.floor(Math.cos(angle) * destLength);
      deltaY = Math.floor(Math.sin(angle) * destLength);
      var dest = new Point(destCenter.x - deltaX,
                           destCenter.y - deltaY);
      var source = new Point(sourceCenter.x + deltaX,
                             sourceCenter.y + deltaY);
      var diffX = dest.x - source.x;
      var diffY = dest.y - source.y;
      var dist = Math.sqrt(diffX*diffX + diffY*diffY);
      var finalWarp = dist*warp;
      if (dist < 35)
      {
        finalWarp = 0;
      }
      var mid = new Point(Math.floor((dest.x + source.x)/2),
                          Math.floor((dest.y + source.y)/2));
      mid.x -= Math.floor(Math.cos(perp)*finalWarp);
      mid.y -= Math.floor(Math.sin(perp)*finalWarp);
      angle = Math.atan2(dest.y - mid.y,
                         dest.x - mid.x);
      var angleX = Math.floor(Math.cos(angle + Math.PI/2)*legLength);
      var angleY = Math.floor(Math.sin(angle + Math.PI/2)*legLength);
      var sX = Math.floor(Math.cos(perp)*3);
      var sY = Math.floor(Math.sin(perp)*3);
      var dX = Math.floor(Math.cos(angle + Math.PI/2)*3);
      var dY = Math.floor(Math.sin(angle + Math.PI/2)*3);
      var backX = Math.floor(Math.cos(angle)*12);
      var backY = Math.floor(Math.sin(angle)*12);
      surface.lineStyle(0, 0x000000);
      surface.beginFill(color);
      surface.moveTo(dest.x - dX - backX, dest.y - dY - backY);
      surface.curveTo(mid.x - sX, mid.y - sY,
                      source.x - sX, source.y - sY);
      surface.lineTo(source.x + sX, source.y + sY);
      surface.curveTo(mid.x + dX, mid.y + dY,
                      dest.x + dX - backX, dest.y + dY - backY);
      surface.lineTo(dest.x + angleX + dX - backX,
                     dest.y + angleY + dY - backY);
      surface.lineTo(dest.x, dest.y);
      surface.lineTo(dest.x - angleX - dX - backX,
                     dest.y - angleY - dY - backY);
      surface.lineTo(dest.x - dX - backX, dest.y - dY - backY);
//      surface.moveTo(source.x, source.y);
//      surface.curveTo(mid.x, mid.y, dest.x, dest.y);
//      surface.lineTo(dest.x, dest.y);
/*
      drawHead(surface, dest, color,
               angle + Math.PI*3/4,
               angle - Math.PI*3/4);
*/
      surface.endFill();
    }

    static function drawHead(surface : Graphics, dest : Point, color : int,
                             leftAngle : Number, rightAngle : Number) : void
    {
      drawLeg(surface, dest, leftAngle);
      drawLeg(surface, dest, rightAngle);
      surface.lineTo(dest.x, dest.y);
    }

    static function drawLeg(surface : Graphics, dest : Point,
                            angle : Number) : void
    {
      var legX = dest.x + Math.floor(Math.cos(angle)*legLength);
      var legY = dest.y + Math.floor(Math.sin(angle)*legLength);
      surface.lineTo(legX, legY);
    }

    static var destLength = 6;
    static var warp = 0.2;
    static var legLength = 9;
    static var wireColor = 0x777777;
  }
}
