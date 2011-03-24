package logic
{
  import flash.utils.ByteArray;

  import lib.Point;

  import ui.WireView;

  public class Wire
  {
    public function Wire(newSource : Point, newDest : Point,
                         newSprite : ui.WireView) : void
    {
      sprite = newSprite;
      source = newSource.clone();
      dest = newDest.clone();
    }

    public function cleanup() : void
    {
      sprite.cleanup();
    }

    public function sendPower(map : Map, power : Boolean) : Part
    {
      var result = null;
      var cell = map.getTile(dest);
      if (cell.part != null)
      {
        var isRoot = cell.part.sendPower(power);
        if (isRoot)
        {
          result = cell.part;
        }
      }
      if (power)
      {
        sprite.show();
      }
      else
      {
        sprite.hide();
      }
      return result;
    }

    public function show() : void
    {
      sprite.show();
    }

    public function hide() : void
    {
      sprite.hide();
    }

    public function getSource() : Point
    {
      return source;
    }

    public function getDest() : Point
    {
      return dest;
    }

    public function changeSource(newSource : Point)
    {
      source = newSource.clone();
      sprite.update(source, dest);
    }

    public function changeDest(newDest : Point)
    {
      dest = newDest.clone();
      sprite.update(source, dest);
    }

    public function save(stream : ByteArray)
    {
      SaveLoad.savePoint(stream, source);
      SaveLoad.savePoint(stream, dest);
    }

    var sprite : ui.WireView;
    var source : Point;
    var dest : Point;
  }
}
