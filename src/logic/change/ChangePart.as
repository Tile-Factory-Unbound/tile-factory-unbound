package logic.change
{
  import lib.Point;
  import lib.Util;

  import logic.Item;
  import logic.Map;
  import logic.Model;
  import logic.Part;
  import logic.PartSpec;
  import logic.Wire;

  import ui.PartView;
  import ui.WireView;
  import ui.View;

  public class ChangePart
  {
    public static function create(spec : PartSpec,
                                  model : Model, view : View) : void
    {
      if (model.getMap().canPlacePart(spec.pos))
      {
        model.getMap().untrackAll(spec.pos);
        var newSprite = new PartView(spec, view.getImages(), view.getAnims());
        var newPart = new logic.Part(spec, newSprite, model.getMap());
        model.addPart(newPart);
        model.getMap().retrackAll(spec.pos);
      }
    }

    public static function destroy(part : Part,
                                   model : Model, view : View) : void
    {
      model.removePart(part);
      part.removeAllTracks();
      model.getMap().retrackAll(part.getPos());
      part.cleanup();
    }

    public static function destroyPartWires(part : Part,
                                            model : Model, view : View) : void
    {
      part.cleanupWires(model.removeWire);
    }

    public static function createSpec(spec : PartSpec,
                                      model : Model, view : View) : void
    {
      model.addSpec(spec);
    }

    public static function destroySpec(spec : PartSpec,
                                       model : Model, view : View) : void
    {
      model.removeSpec(spec);
    }

    public static function pushLine(pos : Point, dir : Dir,
                                    model : Model, view : View) : void
    {
      model.getMap().forEachInLine(pos, dir, pushHelper, null,
                                   dir, model, view);
    }

    static function pushHelper(pos : Point, dir : Dir,
                               model : Model, view : View) : void
    {
      if (model.getMap().getTile(pos).item != null)
      {
        model.getChanges().add(Util.makeChange(ChangeItem.push, pos.clone(),
                                               dir));
      }
    }

    public static function addWire(source : Point, dest : Point,
                                   model : Model, view : View) : void
    {
      if (model.getMap().canStartWire(source)
          && model.getMap().canEndWire(source, dest))
      {
        var oldWire = model.getMap().getTile(dest).part.findWire(source);
        if (oldWire != null)
        {
          model.removeWire(oldWire);
          oldWire.cleanup();
        }
        else
        {
          var newSprite = new WireView(view.getWireParent().getParent(),
                                       source, dest);
          var newWire = new Wire(source, dest, newSprite);
          model.addWire(newWire);
        }
      }
    }

    public static function setNeighbors(pos : Point,
                                        model : Model, view : View) : void
    {
      for each (var dir in Dir.dirs)
      {
        var current = Dir.step(pos, dir);
        if (model.getMap().insideMap(current))
        {
          var cell = model.getMap().getTile(current);
          if (cell.part != null)
          {
            cell.part.setSet();
          }
        }
      }
    }

    public static function clearNeighbors(pos : Point,
                                          model : Model, view : View) : void
    {
      for each (var dir in Dir.dirs)
      {
        var current = Dir.step(pos, dir);
        if (model.getMap().insideMap(current))
        {
          var cell = model.getMap().getTile(current);
          if (cell.part != null)
          {
            cell.part.setClear();
          }
        }
      }
    }

    public static function rotate(pos : Point, isClockwise : Boolean,
                                  model : Model, view : View) : void
    {
      if (model.getMap().insideMap(pos))
      {
        var target = model.getMap().getTile(pos).item;
        if (target != null && (target.isTile() || target.isStencil()))
        {
          target.rotate(isClockwise);
          var part = model.getMap().getTile(pos).part;
          if (part != null)
          {
            part.beginOp(null);
          }
        }
      }
    }

    public static function spray(pos : Point, dir : Dir,
                                 model : Model, view : View) : void
    {
      var sourcePos = Dir.step(pos, dir.opposite());
      var targetPos = Dir.step(pos, dir);
      if (model.getMap().insideMap(sourcePos)
          && model.getMap().insideMap(targetPos))
      {
        var source = model.getMap().getTile(sourcePos).item;
        var target = model.getMap().getTile(targetPos).item;
        if (source != null && target != null && ! source.isTile()
            && target.isTile())
        {
          if (source.isPaint())
          {
            target.paintFrom(source);
          }
          else if (source.isStencil())
          {
            target.stencilFrom(source);
          }
          else if (source.isSolvent())
          {
            target.solvent();
          }
          else if (source.isGlue())
          {
            target.glue();
          }
          var part = model.getMap().getTile(pos).part;
          if (part != null)
          {
            part.beginOp(source);
          }
          model.getChanges().add(Util.makeChange(ChangeItem.shrink, source));
        }
      }
    }

    public static function mix(pos : Point, dir : Dir,
                               model : Model, view : View) : void
    {
      var leftPos = Dir.step(pos, dir.clockwise());
      var rightPos = Dir.step(pos, dir.counter());
      if (model.getMap().insideMap(leftPos)
          && model.getMap().insideMap(rightPos))
      {
        var left = model.getMap().getTile(leftPos).item;
        var right = model.getMap().getTile(rightPos).item;
        if (left != null && right != null && left.isPaint() && right.isPaint())
        {
          var color = left.mixFrom(right);
          model.getChanges().add(Util.makeChange(ChangeItem.create,
                                                 Item.PAINT_BEGIN + color,
                                                 pos.clone(), false));
//          model.getChanges().add(Util.makeChange(ChangeItem.push, pos.clone(),
//                                                 dir));
          model.getChanges().add(Util.makeChange(ChangeItem.shrink, left));
          model.getChanges().add(Util.makeChange(ChangeItem.shrink, right));
          var part = model.getMap().getTile(pos).part;
          if (part != null)
          {
            part.setCreated();
            part.beginOp(null);
          }
        }
      }
    }

    public static function copyItem(pos : Point, dir : Dir,
                                    model : Model, view : View) : void
    {
      var sourcePos = Dir.step(pos, dir.opposite());
      if (model.getMap().insideMap(sourcePos))
      {
        var item = model.getMap().getTile(sourcePos).item;
        if (item != null)
        {
          model.getChanges().add(Util.makeChange(ChangeItem.create,
                                                 item.getType(),
                                                 pos.clone(), false));
//          model.getChanges().add(Util.makeChange(ChangeItem.push, pos.clone(),
//                                                 dir));
          model.getChanges().add(Util.makeChange(ChangeItem.setRotation,
                                                 pos.clone(), item.getDir()));
          model.getChanges().add(Util.makeChange(ChangeItem.setColor,
                                                 pos.clone(),
                                                 item.getColor().clone()));
          var part = model.getMap().getTile(pos).part;
          if (part != null)
          {
            part.setCreated();
          }
//          if (part != null)
//          {
//            part.beginOp(null);
//          }
        }
      }
    }
  }
}
