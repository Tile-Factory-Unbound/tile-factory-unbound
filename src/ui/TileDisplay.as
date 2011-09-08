package ui
{
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.DisplayObjectContainer;
  import flash.events.MouseEvent;
  import lib.Point;

  public class TileDisplay
  {
    public function TileDisplay(newParent : DisplayObjectContainer,
                                newImage : TilePixel,
                                newTile : Boolean,
                                newEdit : Boolean) : void
    {
      parent = newParent;
      if (newImage == null)
      {
        image = new TilePixel();
      }
      else
      {
        image = newImage.clone();
      }
      data = new BitmapData(TileBit.dim, TileBit.dim, true, 0x00000000);
      bitmap = new Bitmap(data);
      parent.addChild(bitmap);
      bitmap.x = -15;
      bitmap.y = -15;
      bitmap.smoothing = false;
      isTile = newTile;
      isEdit = newEdit;
      if (isEdit)
      {
        parent.addEventListener(MouseEvent.MOUSE_DOWN, down);
        Main.getStage().addEventListener(MouseEvent.MOUSE_UP, up);
        parent.addEventListener(MouseEvent.MOUSE_MOVE, move);
      }
      update();
    }

    public function cleanup() : void
    {
      if (isEdit)
      {
        parent.removeEventListener(MouseEvent.MOUSE_DOWN, down);
        Main.getStage().removeEventListener(MouseEvent.MOUSE_UP, up);
        parent.removeEventListener(MouseEvent.MOUSE_MOVE, move);
      }
      bitmap.parent.removeChild(bitmap);
      data.dispose();
    }

    public function reset(newImage : TilePixel) : void
    {
      if (newImage == null)
      {
        image = new TilePixel();
      }
      else
      {
        image = newImage.clone();
      }
      update();
    }

    public function get() : TilePixel
    {
      return image.clone();
    }

    public function paint(color : int) : void
    {
      image.paint(color);
      update();
    }

    public function stencil(mask : TilePixel) : void
    {
      image.addStencil(mask.getStencil());
      update();
    }

    public function solvent() : void
    {
      image.solvent();
      update();
    }

    public function clockwise() : void
    {
      image.clockwise();
      update();
    }

    public function counter() : void
    {
      image.counter();
      update();
    }

    public function flip(isVertical : Boolean) : void
    {
      image.flip(isVertical);
      update();
    }

    public function invert() : void
    {
      image.invert();
      update();
    }

    private function update() : void
    {
      image.drawRegions(data, isTile);
    }

    private function down(event : MouseEvent)
    {
      var pos = getPos(event);
      toggle(pos);
      lastToggle = pos;
    }

    private function up(event : MouseEvent)
    {
      lastToggle = null;
    }

    private function move(event : MouseEvent)
    {
      var pos = getPos(event);
      if (lastToggle != null && ! Point.isEqual(pos, lastToggle))
      {
        toggle(pos);
        lastToggle = pos;
      }
    }

    private function getPos(event : MouseEvent) : Point
    {
      var x = Math.floor(event.localX + 15);
      var y = Math.floor(event.localY + 15);
      return new Point(x, y);
    }

    private function toggle(pos : Point) : void
    {
      if (pos.x >= 0 && pos.x < TileBit.dim &&
          pos.y >= 0 && pos.y < TileBit.dim)
      {
        image.toggleStencil(pos.x, pos.y);
        update();
      }
    }

    var parent : DisplayObjectContainer;
    var bitmap : Bitmap;
    var data : BitmapData;
    var image : TilePixel;
    var isTile : Boolean;
    var isEdit : Boolean;
    var lastToggle : Point;
  }
}
