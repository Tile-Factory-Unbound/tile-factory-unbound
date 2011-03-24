package logic.change
{
  import lib.Point;
  import lib.Util;

  import logic.Item;
  import logic.Map;
  import logic.Model;

  import ui.ItemView;
  import ui.RegionList;
  import ui.View;

  public class ChangeItem
  {
    public static function create(type : int, pos : Point, isStart : Boolean,
                                  model : Model, view : View) : void
    {
      if (model.getMap().canPlaceItem(pos))
      {
        var newSprite = new ItemView(type, pos, view.getImages());
        var newItem = new logic.Item(type, pos, newSprite, isStart);
        model.addItem(newItem);
      }
      else
      {
//        trace("Collision on creation");
        model.getChanges().add(Util.makeChange(ChangeWorld.itemBlocked,
                                               Item.COLLISION, pos));
      }
    }

    public static function destroy(item : Item,
                                   model : Model, view : View) : void
    {
      model.removeItem(item);
      item.cleanup();
    }

    public static function shrink(item : Item,
                                  model : Model, view : View) : void
    {
      var pos = item.getPos();
      item.startShrinking();
      model.getMap().getTile(pos).item = null;
    }

    public static function push(pos : Point, dir : Dir,
                                model : Model, view : View) : void
    {
      var cell = model.getMap().getTile(pos);
      if (cell.item != null)
      {
        cell.item.push(dir, model.getChanges());
      }
    }

    public static function setRotation(pos : Point, dir : Dir,
                                       model : Model, view : View) : void
    {
      var cell = model.getMap().getTile(pos);
      if (cell.item != null)
      {
        cell.item.setRotation(dir);
      }
    }

    public static function setColor(pos : Point, color : ui.RegionList,
                                    model : Model, view : View) : void
    {
      var cell = model.getMap().getTile(pos);
      if (cell.item != null)
      {
        cell.item.setColor(color);
      }
    }

    public static function startMove(pos : Point, dir : Dir,
                                     model : Model, view : View) : void
    {
      var nextPos = Dir.step(pos, dir);
      if (model.getMap().insideMap(pos) && model.getMap().insideMap(nextPos))
      {
        var current = model.getMap().getTile(pos);
        var next = model.getMap().getTile(Dir.step(pos, dir));
        if (current.item != null && next.itemNext == null)
        {
          current.item.moveStarted();
          next.itemNext = current.item;
          current.item = null;
        }
        else
        {
//          trace("Collision on startMove");
          model.getChanges().add(Util.makeChange(ChangeWorld.itemBlocked,
                                                 Item.COLLISION, pos));
          model.getChanges().add(Util.makeChange(ChangeWorld.itemBlocked,
                                                 Item.COLLISION, nextPos));
        }
      }
      else
      {
//        trace("Off the map on startMove");
        model.getChanges().add(Util.makeChange(ChangeWorld.itemBlocked,
                                               Item.COLLISION, pos));
      }
    }

    public static function finishMove(pos : Point,
                                      model : Model, view : View) : void
    {
      var next = model.getMap().getTile(pos);
      if (next.itemNext != null && next.item == null)
      {
        next.item = next.itemNext;
        next.itemNext = null;
      }
      else
      {
//        trace("Collision on finishMove");
        model.getChanges().add(Util.makeChange(ChangeWorld.itemBlocked,
                                               Item.COLLISION, pos));
      }
    }
  }
}
