package ui
{
  import flash.display.DisplayObjectContainer;
  import flash.display.MovieClip;
  import flash.display.Shape;
  import flash.ui.Keyboard;

  import lib.ChangeList;
  import lib.Point;
  import lib.Util;
  import lib.ui.Image;
  import lib.ui.Keyboard;
  import lib.ui.Window;

  import logic.Map;
  import logic.Part;
  import logic.PartSpec;

  import logic.change.ChangePart;

  public class PartPlace
  {
    public function PartPlace(newParent : DisplayObjectContainer,
                              newKeyboard : lib.ui.Keyboard,
                              newWindow : lib.ui.Window) : void
    {
      parent = newParent;
      keyboard = newKeyboard;
      part = new PartSpec(0, new Point(0, 0), Dir.north, true);
      plan = null;
      overlay = null;
      overlayState = NO_OVERLAY;
      changes = null;
      map = null;
      window = newWindow;
      window.addClickCommand(clickMap);
      window.addHoverCommand(hoverMap);
      isEditor = false;
      shouldMove = true;
      moveTarget = null;
    }

    public function setModel(newChanges : lib.ChangeList, newMap : logic.Map,
                             newIsEditor : Boolean,
                             newSetMenu : Function) : void
    {
      changes = newChanges;
      map = newMap;
      isEditor = newIsEditor;
      setMenu = newSetMenu;
    }

    public function cleanup() : void
    {
      cleanupPlan();
    }

    function cleanupPlan() : void
    {
      if (plan != null)
      {
        keyboard.removeHandler(hotkey);
        overlay.parent.removeChild(overlay);
        overlay = null;
        overlayState = NO_OVERLAY;
        plan.parent.removeChild(plan);
        plan = null;
      }
    }

    function cleanupMove() : void
    {
      if (moveTarget != null)
      {
        changes.add(Util.makeChange(ChangePart.destroyPartWires, moveTarget));
        changes.add(Util.makeChange(ChangePart.destroy, moveTarget));
        changes.add(Util.makeChange(ChangePart.destroySpec,
                                    moveTarget.getSpec()));
        moveTarget = null;
      }
    }

    function hotkey(ch : String, code : int) : Boolean
    {
      var used = false;
      if (Part.canRotate(part.type))
      {
        if (ch == "w" || ch == "W")
        {
          part.dir = Dir.north;
          used = true;
        }
        else if (ch == "s" || ch == "S")
        {
          part.dir = Dir.south;
          used = true;
        }
        else if (ch == "d" || ch == "D")
        {
          part.dir = Dir.east;
          used = true;
        }
        else if (ch == "a" || ch == "A")
        {
          part.dir = Dir.west;
          used = true;
        }
        if (used)
        {
          update();
        }
      }
      if (ch == " ")
      {
        if (Part.canPower(part.type))
        {
          part.power = ! part.power;
          used = true;
          update();
        }
      }
      else if (code == flash.ui.Keyboard.BACKSPACE
               || code == flash.ui.Keyboard.DELETE)
      {
        returnToMenu();
        hide();
        show();
        used = true;
      }
      if (used)
      {
        Sound.play(Sound.SELECT);
      }
      return used;
    }

    function clickMap(pos : lib.Point) : Boolean
    {
      var result = true;
      var mapPos = Map.toTile(pos);
      if (shouldMove && plan == null && moveTarget == null)
      {
        startMove(mapPos);
      }
      else if (moveTarget != null)
      {
        finishMove(mapPos);
      }
      else if (plan != null)
      {
        placeNewPart(mapPos);
      }
      else
      {
        result = false;
        Sound.play(Sound.CANCEL);
      }
      return result;
    }
/*


      if (shouldMove && plan == null && moveTarget == null
          && map.getTile(mapPos).part != null
          && (isEditor || map.getTile(mapPos).part.isFixed() == false))
      {
        startMove(mapPos);
      }
      else if (moveTarget != null
               && (map.canPlacePart(mapPos)
                   || (map.insideMap(mapPos)
                       && map.getTile(mapPos).part == moveTarget)))
      {
        finishMove(mapPos);
      }
      else if (plan != null && moveTarget == null)
      {
        placePart(mapPos);
      }
      else if (shouldMove && moveTarget == null
               && map.getTile(mapPos).part != null)
      {
        togglePower(mapPos);
      }
      else
      {
      }
      return result;
    }
*/

    function startMove(mapPos : Point) : void
    {
      if (map.getTile(mapPos).part != null)
      {
        if (isEditor || map.getTile(mapPos).part.isFixed() == false)
        {
          var newSpec = map.getTile(mapPos).part.getSpec();
          setPart(newSpec.type);
          moveTarget = map.getTile(mapPos).part;
          part.pos = newSpec.pos.clone();
          part.dir = newSpec.dir;
          part.power = newSpec.power;
          part.fixed = newSpec.fixed;
          update();
          moveTarget.hide();
          moveTarget.removeAllTracks();
          setMenu(TabList.PLACE_MENU);
          Sound.play(Sound.MOUSE_OVER);
        }
        else
        {
          togglePartPower(mapPos);
        }
      }
      else
      {
        Sound.play(Sound.CANCEL);
      }
    }

    function finishMove(mapPos : Point) : void
    {
      if (map.canPlacePart(mapPos)
          || (map.insideMap(mapPos)
              && map.getTile(mapPos).part == moveTarget))
      {
        var oldPos = moveTarget.getPos();
        map.untrackAll(mapPos);
        map.getTile(oldPos).part = null;
        map.getTile(mapPos).part = moveTarget;
        moveTarget.modifyPart(mapPos, part.dir, part.power);
        moveTarget.show();
        moveTarget = null;
        map.retrackAll(mapPos);
        map.retrackAll(oldPos);
        cleanupPlan();
        setMenu(TabList.PART_MENU);
        Sound.play(Sound.MOUSE_OVER);
      }
      else
      {
        Sound.play(Sound.CANCEL);
      }
    }

    function placeNewPart(mapPos : Point) : void
    {
      if (map.canPlacePart(mapPos))
      {
        part.pos = mapPos;
        var newPart = part.clone();
        changes.add(Util.makeChange(ChangePart.create, newPart));
        changes.add(Util.makeChange(ChangePart.createSpec, newPart));
        if (! keyboard.shift())
        {
          returnToMenu();
          cleanupPlan();
        }
        Sound.play(Sound.MOUSE_OVER);
      }
      else
      {
        Sound.play(Sound.CANCEL);
      }
    }

    function togglePartPower(mapPos : Point) : void
    {
      var target = map.getTile(mapPos).part;
      if (target != null)
      {
        map.untrackAll(mapPos);
        target.modifyPart(mapPos, target.getDir(), ! target.isPowered());
        map.retrackAll(mapPos);
        Sound.play(Sound.MOUSE_OVER);
      }
    }

    public function returnToMenu() : void
    {
      if (part.type <= Part.COPIER)
      {
        setMenu(TabList.PART_MENU);
      }
      else
      {
        setMenu(TabList.ITEM_MENU);
      }
    }

    function hoverMap(pos : lib.Point) : Boolean
    {
      lastPos = null;
      if (pos != null)
      {
        lastPos = pos.clone();
      }
      var result = false;
      if (plan != null)
      {
        result = true;
        if (pos != null)
        {
          plan.visible = true;
          var mapPos = Map.toTile(pos);
          var center = Map.toCenterPixel(mapPos);
          var relPos = window.toRelative(center);
          if (map.insideMap(mapPos))
          {
            plan.x = relPos.x;
            plan.y = relPos.y;
            if (map.canPlacePart(mapPos)
                || map.getTile(mapPos).part == moveTarget)
            {
              if (overlayState != OK_OVERLAY)
              {
                overlayState = OK_OVERLAY;
                drawColorBox(okColor);
              }
            }
            else
            {
              if (overlayState != BAD_OVERLAY)
              {
                overlayState = BAD_OVERLAY;
                drawColorBox(badColor);
              }
            }
          }
          else
          {
            plan.x = window.toRelative(pos).x;
            plan.y = window.toRelative(pos).y;
            overlayState = NO_OVERLAY;
            overlay.graphics.clear();
          }
        }
      }
      return result;
    }

    public function hoverMenu(mouseX : Number, mouseY : Number) : void
    {
      if (plan != null)
      {
        if (Math.floor(plan.x) != Math.floor(mouseX))
        {
          plan.x = mouseX;
        }
        if (Math.floor(plan.y) != Math.floor(mouseY))
        {
          plan.y = mouseY;
        }
        if (overlayState != NO_OVERLAY)
        {
          overlayState = NO_OVERLAY;
          overlay.graphics.clear();
        }
      }
    }

    function drawColorBox(color : int) : void
    {
      var g = overlay.graphics;
      g.clear();
      g.beginFill(color, alphaLevel);
      g.drawRect(-Map.halfTileSize, -Map.halfTileSize,
                 Map.tileSize, Map.tileSize);
      g.endFill();
    }

    public function setPart(newPart : int) : void
    {
      cleanupMove();
      part.type = newPart;
      part.dir = Dir.east;
      if (Part.canPower(part.type))
      {
        part.power = true;
      }
      else
      {
        part.power = false;
      }
      part.fixed = isEditor;
      update();
    }

    public function togglePower() : void
    {
      if (Part.canPower(part.type))
      {
        part.power = ! part.power;
        update();
      }
    }

    public function clockwise() : void
    {
      if (Part.canRotate(part.type))
      {
        part.dir = part.dir.clockwise();
        update();
      }
    }

    public function counter() : void
    {
      if (Part.canRotate(part.type))
      {
        part.dir = part.dir.counter();
        update();
      }
    }

    function update() : void
    {
      var x = parent.stage.mouseX;
      var y = parent.stage.mouseY;
      if (plan != null)
      {
        x = plan.x;
        y = plan.y;
      }
      cleanupPlan();
      keyboard.addHandler(hotkey);
      var linkage = PartView.getLinkage(part.type, part.dir);
      plan = lib.ui.Image.createClip(linkage);
      parent.addChild(plan);
//      plan.visible = false;
      plan.x = x;
      plan.y = y;
      plan.mouseChildren = false;
      plan.mouseEnabled = false;
      overlay = new Shape();
      plan.addChild(overlay);
      overlayState = NO_OVERLAY;
      if (PartView.shouldRotate(part.type))
      {
        plan.rotation = part.dir.toAngle();
      }
      var filters = [];
      if (PartView.shouldGlow(part.type))
      {
        if (part.power)
        {
          filters.push(PartView.glow);
        }
      }
      else if (part.power)
      {
        plan.gotoAndStop(2);
      }
      else
      {
        plan.gotoAndStop(1);
      }
      plan.filters = filters;
      hoverMap(lastPos);
    }

    public function show() : void
    {
      shouldMove = true;
    }

    public function hide() : void
    {
      cleanupPlan();
      cleanupMove();
      shouldMove = false;
    }

    var parent : DisplayObjectContainer;
    var keyboard : lib.ui.Keyboard;
    var window : lib.ui.Window;
    var isEditor : Boolean;
    var plan : MovieClip;
    var overlay : Shape;
    var overlayState : int;
    var changes : lib.ChangeList;
    var map : logic.Map;
    var part : logic.PartSpec;
    var lastPos : Point;
    var shouldMove : Boolean;
    var moveTarget : Part;
    var setMenu : Function;

    static var okColor : int = 0x33ff33;
    static var badColor : int = 0xff3333;
    static var alphaLevel : Number = 0.5;

    static var NO_OVERLAY = 0;
    static var OK_OVERLAY = 1;
    static var BAD_OVERLAY = 2;
  }
}
