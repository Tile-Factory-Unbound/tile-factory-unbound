package logic
{
  import lib.ChangeList;
  import lib.Point;
  import lib.Util;

  import logic.change.ChangeItem;

  import ui.ItemView;
  import ui.RegionList;

  public class Item
  {
    public static var COLLISION = 0;
    public static var JAM = 1;

    public static var TILE = 1;
    public static var SOLVENT = 2;
    public static var GLUE = 3;
    public static var STENCIL_BEGIN = 4;
    public static var STENCIL_END = 9;
    public static var PAINT_BEGIN = 9;
    public static var PAINT_END = 25;

    public function Item(newType : int, newPos : Point,
                         newSprite : ui.ItemView, newIsStart : Boolean) : void
    {
      type = newType;
      pos = newPos.clone();
      sprite = newSprite;
      isStart = newIsStart;

      group = new Group(this);
      sticky = false;
      hasStuck = false;
      didMove = false;
      isRotating = false;
      isClockwise = false;
      hasSprayed = false;
      isShrinking = false;
      isGrowing = ! isStart;
      dir = Dir.east;

      if (isStart)
      {
        sprite.normalSize();
      }

      color = new RegionList();
      if (isTile())
      {
        sprite.updateColor(color);
      }
      else
      {
        sprite.updateColor(null);
      }
      if (isPaint())
      {
        color.setColor(0, type - PAINT_BEGIN);
      }
      else if (isStencil())
      {
        color.addStencil(RegionList.stencils[type - STENCIL_BEGIN]);
      }
    }

    public function cleanup() : void
    {
      sprite.cleanup();
      group.removeMember(this);
    }

    public function getPos() : Point
    {
      return pos;
    }

    public function getPixelPos() : Point
    {
      return sprite.getPos();
    }

    public function getDir() : Dir
    {
      return dir;
    }

    public function getType() : int
    {
      return type;
    }

    public function getGroup() : Group
    {
      return group;
    }

    public function hasColor(other : RegionList) : Boolean
    {
      return isTile() && RegionList.isEqual(color, other);
    }

    public function push(newDir : Dir, changes : lib.ChangeList) : void
    {
      group.addForce(newDir, changes);
    }

    public function step(changes : lib.ChangeList) : void
    {
      if (isRotating)
      {
        isRotating = false;
        if (isClockwise)
        {
          color.clockwise();
          dir = dir.clockwise();
        }
        else
        {
          color.counter();
          dir = dir.counter();
        }
        if (isTile())
        {
          sprite.updateRotation(Dir.east);
          sprite.updateColor(color);
        }
        else
        {
          sprite.updateRotation(dir);
        }
      }
      if (group.hasForce())
      {
        didMove = true;
        changes.add(Util.makeChange(ChangeItem.startMove, pos.clone(),
                                    group.getForce()));
      }
    }

    public function moveStarted() : void
    {
      if (didMove)
      {
        pos = Dir.step(pos, group.getForce());
      }
    }

    public function finalize(changes : lib.ChangeList) : void
    {
      if (didMove)
      {
        didMove = false;
        changes.add(Util.makeChange(ChangeItem.finishMove, pos.clone()));
      }
      if (isGrowing)
      {
        isGrowing = false;
        sprite.normalSize();
      }
    }

    public function animate() : void
    {
      if (group.hasForce())
      {
        sprite.moveDir(group.getForce(), Model.MOVE_SPEED);
      }
      if (isRotating)
      {
        if (isClockwise)
        {
          sprite.rotate(ROTATE_INCREMENT);
        }
        else
        {
          sprite.rotate(-ROTATE_INCREMENT);
        }
      }
      if (isShrinking)
      {
        sprite.shrink();
      }
      else if (isGrowing)
      {
        sprite.grow();
      }
    }

    public function startShrinking() : void
    {
      isShrinking = true;
    }

    static var ROTATE_INCREMENT = 90 / Model.DELAY_MAX;

    public function clearForce(changes : ChangeList) : void
    {
      if (hasSprayed)
      {
        sprite.updateColor(color);
        sprite.updateSticky(sticky);
        hasSprayed = false;
      }
      group.clearForce();
      sprite.move(pos);
      if (isShrinking)
      {
        changes.add(Util.makeChange(ChangeItem.destroy, this));
      }
    }

    public function rotate(newClockwise : Boolean) : void
    {
      if ((isTile() || isStencil()) && ! group.isGlued())
      {
        isRotating = true;
        isClockwise = newClockwise;
      }
    }

    public function setRotation(newDir : Dir) : void
    {
      if (isStencil())
      {
        while (dir != newDir)
        {
          color.clockwise();
          dir = dir.clockwise();
        }
      }
      sprite.updateRotation(dir);
      isRotating = false;
    }

    public function paintFrom(other : Item) : void
    {
      if (isTile() && other.isPaint())
      {
        color.paint(other.color.getColor(0));
        hasSprayed = true;
      }
    }

    public function getColor() : ui.RegionList
    {
      return color;
    }

    public function setColor(newColor : ui.RegionList) : void
    {
      if (isTile())
      {
        color.copyFrom(newColor);
        sprite.updateColor(color);
        hasSprayed = true;
      }
    }

    public function stencilFrom(other : Item) : void
    {
      if (isTile() && other.isStencil())
      {
        color.addStencil(other.color.getStencil());
        hasSprayed = true;
      }
    }

    public function solvent() : void
    {
      if (isTile())
      {
        color.solvent();
        if (group.isGlued())
        {
          group = group.spawn(this);
        }
        sticky = false;
        hasSprayed = true;
//        sprite.updateSticky(sticky);
      }
    }

    public function glue() : void
    {
      if (isTile())
      {
        sticky = true;
        hasSprayed = true;
//        sprite.updateSticky(sticky);
      }
    }

    public function changeGroup(newGroup : Group) : void
    {
      group = newGroup;
    }

    public function checkSticky(other : Item, changes : ChangeList)
    {
      if (isTile() && other.isTile() && (sticky || other.sticky)
          && group != other.group)
      {
        group.mergeFrom(other.group, changes);
        hasStuck = true;
        other.hasStuck = true;
      }
    }

    public function finalizeSticky() : void
    {
      if (hasStuck)
      {
        sticky = false;
        hasStuck = false;
//        hasSprayed = true;
        sprite.updateSticky(sticky);
      }
    }

    public function mixFrom(other : Item) : int
    {
      var result = 0;
      if (isPaint() && other.isPaint())
      {
        result = RegionList.mix(color.getColor(0),
                                other.color.getColor(0));
      }
      return result;
    }

    public function isTile() : Boolean
    {
      return type == TILE;
    }

    public function isPaint() : Boolean
    {
      return type >= PAINT_BEGIN && type < PAINT_END;
    }

    public function isSolvent() : Boolean
    {
      return type == SOLVENT;
    }

    public function isGlue() : Boolean
    {
      return type == GLUE;
    }

    public function isStencil() : Boolean
    {
      return type >= STENCIL_BEGIN && type < STENCIL_END;
    }

    public function isSticky() : Boolean
    {
      return sticky;
    }

    var type : int;
    var pos : Point;
    var sprite : ui.ItemView;
    var group : Group;
    var sticky : Boolean;
    var hasStuck : Boolean;
    var didMove : Boolean;
    var isRotating : Boolean;
    var isClockwise : Boolean;
    var hasSprayed : Boolean;
    var isShrinking : Boolean;
    var isGrowing : Boolean;
    var isStart : Boolean;

    var color : ui.RegionList;
    var dir : Dir;
  }
}
