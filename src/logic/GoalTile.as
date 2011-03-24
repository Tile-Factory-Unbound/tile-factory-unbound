package logic
{
  import lib.Point;
  import lib.ChangeList;
  import lib.Util;

  import logic.change.ChangeItem;

  import ui.RegionList;
  import ui.GoalTileView;

  public class GoalTile
  {
    public function GoalTile(newSprite : GoalTileView,
                             newPos : Point) : void
    {
      sprite = newSprite;
      pos = newPos.clone();
      color = new RegionList();
      sprite.updateColor(color);
    }

    public function cleanup() : void
    {
      sprite.cleanup();
    }

    public function check(map : Map) : Group
    {
      var result = null;
      var item = map.getTile(pos).item;
      if (item != null && item.isTile() && item.hasColor(color))
      {
        result = item.getGroup();
      }
      return result;
    }

    public function removeItem(map : Map, changes : ChangeList) : void
    {
      var item = map.getTile(pos).item;
      if (item != null)
      {
        changes.add(Util.makeChange(ChangeItem.destroy, item));
      }
    }

    public function getPos() : Point
    {
      return pos;
    }

    public function getColor() : RegionList
    {
      return color.clone();
    }

    public function changeColor(newColor : RegionList) : void
    {
      color.copyFrom(newColor);
      sprite.updateColor(color);
    }

    public function move(dir : Dir) : void
    {
      Dir.stepMod(pos, dir);
      sprite.updatePos(pos);
    }

    var sprite : ui.GoalTileView;
    var pos : lib.Point;
    var color : ui.RegionList;
  }
}
