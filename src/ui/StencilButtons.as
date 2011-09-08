package ui
{
  public class StencilButtons
  {
    public function StencilButtons(clips : Array,
                                   newColors : Array) : void
    {
      colors = newColors;
      tiles = new Array();
      var i = 0;
      for (; i < colors.length; ++i)
      {
        var tile = new TileDisplay(clips[i], colors[i], false, false);
        tiles.push(tile);
      }
    }

    public function cleanup() : void
    {
      for each (var tile in tiles)
      {
        tile.cleanup();
      }
    }

    public function reset()
    {
      var i = 0;
      for (; i < colors.length; ++i)
      {
        tiles[i].reset(colors[i]);
      }
    }

    public function get(index : int) : TilePixel
    {
      return tiles[index].get();
    }

    public function clockwise()
    {
      for each (var tile in tiles)
      {
        tile.clockwise();
      }
    }

    public function counter()
    {
      for each (var tile in tiles)
      {
        tile.counter();
      }
    }

    public function flip(isVertical : Boolean)
    {
      for each (var tile in tiles)
      {
        tile.flip(isVertical);
      }
    }

    public function invert()
    {
      for each (var tile in tiles)
      {
        tile.invert();
      }
    }

    var colors : Array;
    var tiles : Array;
  }
}
