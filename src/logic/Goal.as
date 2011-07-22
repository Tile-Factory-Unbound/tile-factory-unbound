package logic
{
  import flash.utils.ByteArray;

  import lib.Box;
  import lib.ChangeList;
  import lib.Point;

  import ui.GoalView;
  import ui.Sound;
  import ui.TilePixel;

  public class Goal
  {
    public function Goal(newSprite : GoalView, newArea : Box) : void
    {
      sprite = newSprite;
      area = newArea.clone();
      count = START_COUNT;
      tiles = new Array();
      sprite.updateCount(count);
    }

    public function cleanup() : void
    {
      for each (var tile in tiles)
      {
        tile.cleanup();
      }
      sprite.cleanup();
    }

    public function reset() : void
    {
      count = START_COUNT;
      sprite.updateCount(count);
    }

    public function getBounds() : Box
    {
      return area;
    }

    public function check(map : Map, changes : ChangeList) : Boolean
    {
      var group = null;
      var passed = true;
      for each (var tile in tiles)
      {
        var newGroup = tile.check(map);
        if (newGroup != null && (group == null || newGroup == group))
        {
          group = newGroup;
        }
        else
        {
          passed = false;
          break;
        }
      }
      passed = passed && group != null && group.getSize() == tiles.length;
      if (passed)
      {
        removeItems(map, changes);
        --count;
        Sound.play(Sound.PLACE);
      }
      sprite.updateCount(count);
      return count <= 0;
    }

    function removeItems(map : Map, changes : ChangeList) : void
    {
      for each (var tile in tiles)
      {
        tile.removeItem(map, changes);
      }
    }

    public function getTile(pos : Point) : TilePixel
    {
      var result = null;
      var index = findTile(pos);
      if (index != -1)
      {
        result = tiles[index].getColor();
      }
      return result;
    }

    public function changeTile(pos : Point, color : TilePixel) : void
    {
      var index = findTile(pos);
      if (index != -1)
      {
        tiles[index].changeColor(color);
      }
      else
      {
        var newTile = new GoalTile(sprite.makeTileSprite(pos), pos);
        newTile.changeColor(color);
        tiles.push(newTile);
      }
    }

    public function removeTile(pos : Point) : void
    {
      var index = findTile(pos);
      if (index != -1)
      {
        tiles[index].cleanup();
        tiles.splice(index, 1);
      }
    }

    function findTile(pos : Point) : int
    {
      var result = -1;
      var i = 0;
      for (; i < tiles.length; ++i)
      {
        if (Point.isEqual(pos, tiles[i].getPos()))
        {
          result = i;
          break;
        }
      }
      return result;
    }

    public function contains(pos : Point) : Boolean
    {
      return area.contains(pos);
    }

    public function save(stream : ByteArray) : void
    {
      SaveLoad.savePoint(stream, area.getOffset());
      SaveLoad.savePoint(stream, area.getLimit());
      stream.writeShort(tiles.length);
      for each (var posTile in tiles)
      {
        SaveLoad.savePoint(stream, posTile.getPos());
      }
      for each (var colorTile in tiles)
      {
        colorTile.getColor().save(stream);
      }
    }

    public function showNormal() : void
    {
      sprite.updateBounds(area, GoalView.boxColorNormal);
    }

    public function showSelected() : void
    {
      sprite.updateBounds(area, GoalView.boxColorSelected);
    }

    public function move(dir : Dir, map : Map) : void
    {
      var oldOffset = area.getOffset();
      area.moveTo(Dir.step(oldOffset, dir));
      if (map.insideMapBox(area))
      {
        sprite.updateBounds(area, GoalView.boxColorSelected);
        for each (var tile in tiles)
        {
          tile.move(dir);
        }
      }
      else
      {
        area.moveTo(oldOffset);
      }
    }

    public function expand(dir : Dir, map : Map) : void
    {
      var newArea = Dir.extend(area, dir, 1);
      if (map.insideMapBox(newArea))
      {
        area = newArea;
        sprite.updateBounds(area, GoalView.boxColorSelected);
      }
    }

    public function contract(dir : Dir, map : Map) : void
    {
      var newArea = Dir.remainder(area, dir, 1);
      var tilesFit = true;
      for each (var tile in tiles)
      {
        if (! newArea.contains(tile.getPos()))
        {
          tilesFit = false;
          break;
        }
      }
      if (tilesFit && newArea.getSize().x >= minSize.x
          && newArea.getSize().y >= minSize.y)
      {
        area = newArea;
        sprite.updateBounds(newArea, GoalView.boxColorSelected);
      }
    }

    var sprite : ui.GoalView;
    var area : lib.Box;
    var count : int;
    var tiles : Array;

    static var START_COUNT = 5;
//    static var START_COUNT = 40;
    static var minSize = new Point(3, 3);
  }
}
