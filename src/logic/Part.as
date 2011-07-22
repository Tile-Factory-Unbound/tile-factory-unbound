package logic
{
  import lib.ChangeList;
  import lib.Point;
  import lib.Util;

  import logic.change.ChangeItem;
  import logic.change.ChangePart;

  import ui.PartView;

  public class Part
  {
    public static var ALL = 0;
    public static var SOME = 1;
    public static var NONE = 2;
    public static var MEM = 3;
    public static var SET = 4;
    public static var CLEAR = 5;

    public static var CONVEYER = 6;
    public static var BARRIER = 7;
    public static var ROTATER = 8;
    public static var SENSOR = 9;
    public static var SPRAYER = 10;
    public static var MIXER = 11;
    public static var COPIER = 12;

    public static var TILE = 13;
    public static var SOLVENT = 14;
    public static var GLUE = 15;

    public static var STENCIL_BEGIN = 16;
    public static var TRIANGLE = 16;
    public static var RECTANGLE = 17;
    public static var SMALL_CIRCLE = 18;
    public static var CIRCLE = 19;
    public static var BIG_CIRCLE = 20;
    public static var STENCIL_END = 21;

    public static var PAINT_BEGIN = 21;
    public static var WHITE = 21;
    public static var CYAN = 22;
    public static var MAGENTA = 23;
    public static var YELLOW = 24;
    public static var BLACK = 25;
    public static var PAINT_END = 26;

    static var paintType = [0x0, 0x8, 0x4, 0x2, 0x1];

    public static function isItem(type : int) : Boolean
    {
      return type >= TILE;
    }

    public static function canRotate(type : int) : Boolean
    {
      return type == CONVEYER || type == ROTATER || type == SPRAYER
        || type == MIXER || type == COPIER
        || (type >= STENCIL_BEGIN && type < STENCIL_END);
    }

    public static function canPower(type : int) : Boolean
    {
      return type < TILE && type != BARRIER;
    }

    public function Part(newSpec : PartSpec, newSprite : ui.PartView,
                         newMap : Map) : void
    {
      spec = newSpec;
      type = spec.type;
      pos = spec.pos.clone();
      dir = spec.dir;
      power = spec.power;
      memPower = spec.power;
      shouldSet = false;
      shouldClear = false;
      didCreate = false;
      inputs = new Array();
      outputs = new Array();
      sprite = newSprite;
      parentsLeft = 0;
      map = newMap;
    }

    public function cleanup()
    {
      sprite.cleanup();
    }

    public function cleanupWires(f : Function) : void
    {
      var next = null;
      while (inputs.length > 0)
      {
        next = inputs[0];
        f(next);
        next.cleanup();
      }
      while (outputs.length > 0)
      {
        next = outputs[0];
        f(next);
        next.cleanup();
      }
    }

    public function getPos() : Point
    {
      return pos;
    }

    public function getDir() : Dir
    {
      return dir;
    }

    public function getSpec() : PartSpec
    {
      return spec;
    }

    public function modifyPart(newPos : Point, newDir : Dir,
                               newPower : Boolean) : void
    {
      // Change Dir
      dir = newDir;
      spec.dir = newDir;
      sprite.updateDir(dir);

      // Change Pos
      pos = newPos.clone();
      spec.pos = newPos.clone();
      sprite.updatePos(pos);
      for each (var output in outputs)
      {
        output.changeSource(pos);
      }
      for each (var input in inputs)
      {
        input.changeDest(pos);
      }

      // Change Power
      power = newPower;
      memPower = newPower;
      spec.power = newPower;
      sprite.updatePower(newPower);
    }

    public function show() : void
    {
      sprite.show();
    }

    public function hide() : void
    {
      sprite.hide();
    }


    public function showWires() : void
    {
      for each (var input in inputs)
      {
        input.show();
      }
      for each (var output in outputs)
      {
        output.show();
      }
    }

    public function hideWires() : void
    {
      for each (var input in inputs)
      {
        input.hide();
      }
      for each (var output in outputs)
      {
        output.hide();
      }
    }

    public function isConveyer() : Boolean
    {
      return type == CONVEYER;
    }

    public function isBarrier() : Boolean
    {
      return isBarrierType(type);
    }

    public static function isBarrierType(type : int) : Boolean
    {
      return type == BARRIER || type == SPRAYER || type == MIXER
        || type == COPIER;
    }

    public function startPlay(changes : lib.ChangeList) : void
    {
      if (type >= TILE)
      {
        var itemType = type - TILE + 1;
        if (type >= PAINT_BEGIN && type < PAINT_END)
        {
          itemType = Item.PAINT_BEGIN + paintType[type - PAINT_BEGIN];
        }
        changes.add(Util.makeChange(ChangeItem.create, itemType, pos.clone(),
                                    true));
        if (type >= STENCIL_BEGIN && type < STENCIL_END)
        {
          changes.add(Util.makeChange(ChangeItem.setRotation, pos.clone(),
                                      dir));
        }
        hide();
      }
      updatePower();
    }

    public function stepConveyer(changes : lib.ChangeList) : void
    {
      if (power)
      {
        if (type == CONVEYER)
        {
          changes.add(Util.makeChange(ChangePart.pushLine, pos.clone(), dir));
        }
        else if (didCreate && (type == MIXER || type == COPIER))
        {
//          changes.add(Util.makeChange(ChangePart.mix, pos.clone(), dir));
          didCreate = false;
          changes.add(Util.makeChange(ChangeItem.push, pos.clone(),
                                      dir));
        }
      }
    }

    public function stepRotater(changes : lib.ChangeList) : void
    {
      if (power && type == ROTATER)
      {
        var isClockwise = (dir == Dir.east || dir == Dir.north);
        changes.add(Util.makeChange(ChangePart.rotate, pos.clone(),
                                    isClockwise));
      }
    }

    public function step(changes : lib.ChangeList) : void
    {
      if (power)
      {
        if (type == SET)
        {
          changes.add(Util.makeChange(ChangePart.setNeighbors, pos.clone()));
        }
        else if (type == CLEAR)
        {
          changes.add(Util.makeChange(ChangePart.clearNeighbors, pos.clone()));
        }
        else if (type == SPRAYER)
        {
          changes.add(Util.makeChange(ChangePart.spray, pos.clone(), dir));
        }
        else if (type == COPIER)
        {
          sprite.animate(null);
          changes.add(Util.makeChange(ChangePart.copyItem, pos.clone(), dir));
        }
        else if (type == MIXER)
        {
          changes.add(Util.makeChange(ChangePart.mix, pos.clone(), dir));
        }
      }
    }

    public function setCreated() : void
    {
      didCreate = true;
    }

    public function beginOp(source : Item) : void
    {
      sprite.animate(source);
    }

    public function updateSensor(map : Map)
    {
      if (type == SENSOR)
      {
        power = (map.getTile(pos).item != null);
        updatePower();
      }
    }

    public function canWire() : Boolean
    {
      return type != BARRIER && ! isItem(type);
    }

    public function canStartWire() : Boolean
    {
      return type == SENSOR || type == ALL || type == SOME || type == NONE
        || type == MEM;
    }

    public function canEndWire(source : lib.Point, map : Map) : Boolean
    {
      var parent = map.getTile(source).part;
      return parent != null && type != SENSOR && type != BARRIER && type < TILE
        && ! hasChild(map, parent);
    }

    public function findWire(source : lib.Point) : Wire
    {
      var result = null;
      for each (var input in inputs)
      {
        if (Point.isEqual(input.getSource(), source))
        {
          result = input;
          break;
        }
      }
      return result;
    }

    function hasChild(map : Map, parent : Part) : Boolean
    {
      var result = false;
      if (type != MEM)
      {
        for each (var out in outputs)
        {
          var next = map.getTile(out.getDest()).part;
          result = result || next == parent || next.hasChild(map, parent);
          if (result)
          {
            break;
          }
        }
      }
      return result;
    }

    public function resetLogic() : void
    {
      parentsLeft = inputs.length;
      if (type == MEM)
      {
        if (shouldSet && shouldClear)
        {
          power = !power;
          memPower = power;
        }
        else if (shouldSet)
        {
          power = true;
          memPower = true;
        }
        else if (shouldClear)
        {
          power = false;
          memPower = false;
        }
        else
        {
          power = memPower;
        }
        shouldSet = false;
        shouldClear = false;
        updatePower();
      }
      if (parentsLeft > 0)
      {
        if (type == ALL || type == NONE)
        {
          power = true;
        }
        else if (type == MEM)
        {
          memPower = false;
        }
        else
        {
          power = false;
        }
      }
    }

    public function powerChildren(map : Map, roots : Array,
                                  updatePower : Boolean) : void
    {
      for each (var wire in outputs)
      {
        var next = wire.sendPower(map, power, updatePower);
        if (next != null)
        {
          roots.push(next);
        }
      }
    }

    public function sendPower(newPower : Boolean) : Boolean
    {
      --parentsLeft;
      if (type == ALL)
      {
        if (!newPower)
        {
          power = false;
        }
      }
      else if (type == NONE)
      {
        if (newPower)
        {
          power = false;
        }
      }
      else if (type == MEM)
      {
        if (newPower && !memPower)
        {
          memPower = newPower;
        }
      }
      else
      {
        if (newPower && !power)
        {
          power = newPower;
        }
      }
      if (parentsLeft <= 0)
      {
        updatePower();
      }
      return parentsLeft <= 0 && type != MEM;
    }

    public function setSet() : void
    {
      shouldSet = true;
    }

    public function setClear() : void
    {
      shouldClear = true;
    }

    public function isRoot() : Boolean
    {
      return parentsLeft <= 0 || type == MEM;
    }

    public function addAllTracks() : void
    {
      if (type == CONVEYER)
      {
        map.forEachInLine(pos, dir, addTrack, this);
      }
    }

    function addTrack(trackPos : Point) : void
    {
      if (! Point.isEqual(pos, trackPos))
      {
        if (map.getTile(trackPos).track == null)
        {
          map.getTile(trackPos).track = new Track(sprite.getTrackSprite(),
                                                  trackPos, this);
        }
        else
        {
          map.getTile(trackPos).track.addParent(this);
        }
      }
    }

    public function removeAllTracks() : void
    {
      if (type == CONVEYER)
      {
        map.forEachInLine(pos, dir, removeTrack, this);
      }
    }

    function removeTrack(trackPos : Point) : void
    {
      if (! Point.isEqual(pos, trackPos))
      {
        map.getTile(trackPos).track.removeParent(this);
      }
    }

    function updatePower() : void
    {
      if (type == CONVEYER)
      {
        map.forEachInLine(pos, dir, updateTrack, this);
      }
      sprite.updatePower(power);
    }

    function updateTrack(trackPos : Point)
    {
      if (! Point.isEqual(pos, trackPos))
      {
        map.getTile(trackPos).track.update();
      }
    }

    public function addInput(newWire : Wire)
    {
      inputs.push(newWire);
    }

    public function removeInput(oldWire : Wire)
    {
      var index = inputs.indexOf(oldWire);
      if (index != -1)
      {
        inputs.splice(index, 1);
      }
    }

    public function addOutput(newWire : Wire)
    {
      outputs.push(newWire);
    }

    public function removeOutput(oldWire : Wire)
    {
      var index = outputs.indexOf(oldWire);
      if (index != -1)
      {
        outputs.splice(index, 1);
      }
    }

    public function isFixed() : Boolean
    {
      return spec.fixed;
    }

    public function isPowered() : Boolean
    {
      return power;
    }

    private var spec : PartSpec;
    private var type : int;
    private var pos : Point;
    private var dir : Dir;
    private var power : Boolean;
    private var memPower : Boolean;
    private var shouldSet : Boolean;
    private var shouldClear : Boolean;
    private var didCreate : Boolean;
    private var inputs : Array;
    private var outputs : Array;
    private var sprite : ui.PartView;
    private var parentsLeft : int;
    private var map : Map;
  }
}
