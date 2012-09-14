package
{
  import flash.utils.ByteArray;
  import lib.Box;
  import lib.Point;
  import lib.external.Base64;

  import logic.ButtonStatus;
  import logic.PartSpec;
  import logic.WireSpec;
  import logic.GoalSpec;
  import ui.RegionList;
  import ui.TilePixel;

  public class SaveLoad
  {
    public static var LOAD_ALL = 0;
    public static var LOAD_LEVEL = 1;
    public static var LOAD_SAVE = 2;

    public static function loadMap(text : String, size : Point, parts : Array,
                                   wires : Array, goals : Array,
                                   buttonStatus : logic.ButtonStatus,
                                   stencils : Array,
                                   setName : Function, loadType : int) : void
    {
      if (loadType == LOAD_ALL || loadType == LOAD_LEVEL)
      {
        parts.splice(0, parts.length);
        goals.splice(0, goals.length);
      }
      if (loadType == LOAD_ALL || loadType == LOAD_SAVE)
      {
        wires.splice(0, wires.length);
      }
      var r = new RegExp("\\s", "g");
      var line = text.replace(r, "");
      var stream = Base64.decodeToByteArray(line);
      stream.uncompress();
      var version = stream.readUnsignedByte();
      if (version > CURRENT_VERSION)
      {
        trace("Unknown version: " + version);
        throw new Error("Unknown version: " + version);
      }
      var name = "";
      if (version > 0)
      {
        name = stream.readUTF();
      }
      var sizeX = stream.readUnsignedByte();
      var sizeY = stream.readUnsignedByte();
      if (loadType == LOAD_ALL || loadType == LOAD_LEVEL)
      {
        if (version > 0)
        {
          setName(name);
        }
        size.x = sizeX;
        size.y = sizeY;
      }
      loadParts(stream, parts, buttonStatus, loadType, version);
      loadWires(stream, wires, loadType);
      loadGoals(stream, goals, loadType, version);
      if (version > 0)
      {
        var newStatus = stream.readUnsignedInt();
        if (loadType == LOAD_ALL || loadType == LOAD_LEVEL)
        {
          if (version == 1)
          {
            newStatus = (newStatus & 0x1ff) |
              ((newStatus & 0xfffffe00) << 2);
          }
          buttonStatus.setAllStatus(newStatus);
        }
      }
      if (version > 1)
      {
        loadStencils(stream, stencils);
      }
    }

    static function loadParts(stream : ByteArray, parts : Array,
                              buttonStatus : logic.ButtonStatus,
                              loadType : int, version : int) : void
    {
      var count = stream.readUnsignedShort();
      var i = 0;
      for (; i < count; ++i)
      {
        var type = stream.readUnsignedByte();
        if (version < 2 && type >= 9)
        {
          type += 2;
        }
        var pos = loadPoint(stream);
        var dirPower = stream.readUnsignedByte();
        var dir = Dir.dirs[dirPower & 0x3];
        var power = true;
        if ((dirPower & 0x4) == 0)
        {
          power = false;
        }
        var fixed = true;
        if ((dirPower & 0x8) == 0)
        {
          fixed = false;
        }
        var locked = true;
        if ((dirPower & 0x10) == 0)
        {
          locked = false;
        }
        if (locked)
        {
          fixed = true;
        }
        var shouldLoad = (loadType == LOAD_ALL);
        if (! shouldLoad)
        {
          shouldLoad = (loadType == LOAD_LEVEL && fixed);
        }
        if (! shouldLoad)
        {
          shouldLoad = (!fixed && partAllowed(type, buttonStatus)
                        && ! partBlocked(pos, parts));
        }
        if (shouldLoad)
        {
          var newPart = new logic.PartSpec(type, pos, dir, power);
          newPart.fixed = fixed;
          newPart.locked = locked;
          parts.push(newPart);
        }
        else
        {
          updatePower(type, dir, fixed, power, pos, parts);
        }
      }
    }

    static function partAllowed(type : int,
                                buttonStatus : logic.ButtonStatus) : Boolean
    {
      return buttonStatus.getStatus(type);
    }

    static function findPos(pos : Point, parts : Array) : PartSpec
    {
      var result = null;
      for each (var current in parts)
      {
        if (Point.isEqual(pos, current.pos))
        {
          result = current;
          break;
        }
      }
      return result;
    }

    static function partBlocked(pos : Point, parts : Array) : Boolean
    {
      return findPos(pos, parts) != null;
    }

    static function updatePower(type : int, dir : Dir, fixed : Boolean,
                                power : Boolean, pos : Point,
                                parts : Array) : void
    {
      var part = findPos(pos, parts);
      if (part != null)
      {
        if (part.type == type && part.dir == dir && part.fixed == fixed)
        {
          part.power = power;
        }
      }
    }

    static function loadWires(stream : ByteArray, wires : Array,
                              loadType : int) : void
    {
      var count = stream.readUnsignedShort();
      var i = 0;
      for (; i < count; ++i)
      {
        var source = loadPoint(stream);
        var dest = loadPoint(stream);
        if (loadType == LOAD_ALL || loadType == LOAD_SAVE)
        {
          wires.push(new logic.WireSpec(source, dest));
        }
      }
    }

    static function loadGoals(stream : ByteArray, goals : Array,
                              loadType : int, version : int) : void
    {
      var count = stream.readUnsignedByte();
      var i = 0;
      for (; i < count; ++i)
      {
        var offset = loadPoint(stream);
        var limit = loadPoint(stream);
        var current = new GoalSpec(new Box(offset, limit));
        var tileCount = stream.readUnsignedShort();
        var posList = new Array();
        var colorList = new Array();
        var j = 0;
        for (j = 0; j < tileCount; ++j)
        {
          var pos = loadPoint(stream);
          current.pos.push(pos);
        }
        for (j = 0; j < tileCount; ++j)
        {
          var pixelColor = new TilePixel();
          if (version <= 1)
          {
            var cyan = stream.readUnsignedInt();
            var magenta = stream.readUnsignedInt();
            var yellow = stream.readUnsignedInt();
            var absorb = stream.readUnsignedInt();
            var stencil = stream.readUnsignedInt();
            var color = new ui.RegionList();
            color.reset(cyan, magenta, yellow, absorb, stencil);
            var k = 0;
            for (; k < 32; ++k)
            {
              var currentColor = color.getColor(k);
              if (currentColor == 0xf)
              {
                color.setColor(k, 0x1);
              }
              else if (currentColor == 0x1)
              {
                color.setColor(k, 0xf);
              }
            }
            pixelColor.convertFrom(color);
          }
          else
          {
            pixelColor.load(stream);
          }
          current.color.push(pixelColor);
        }
        if (loadType == LOAD_ALL || loadType == LOAD_LEVEL)
        {
          goals.push(current);
        }
      }
    }

    static function loadStencils(stream : ByteArray, stencils : Array) : void
    {
      var count = stream.readUnsignedByte();
      if (count > GameSettings.STENCIL_COUNT)
      {
        count = GameSettings.STENCIL_COUNT;
      }
      var i = 0;
      for (; i < count; ++i)
      {
        var color = new TilePixel();
        color.loadStencil(stream);
        stencils[i] = color;
      }
    }

    static function loadPoint(stream : ByteArray) : Point
    {
      var result = new Point(0, 0);
      result.x = stream.readUnsignedByte();
      result.y = stream.readUnsignedByte();
      return result;
    }

    public static function saveMap(size : Point, parts : Array,
                                   wires : Array, goals : Array,
                                   buttonStatus : logic.ButtonStatus,
                                   stencils : Array,
                                   name : String) : String
    {
      var stream = new ByteArray();
      stream.writeByte(CURRENT_VERSION);
      stream.writeUTF(name);
      savePoint(stream, size);
      saveParts(stream, parts);
      saveWires(stream, wires);
      saveGoals(stream, goals);
      stream.writeUnsignedInt(buttonStatus.getAllStatus());
      saveStencils(stream, stencils);
      stream.compress();
      var line = Base64.encodeByteArray(stream);
      var lineList = [];
      var start = 0;
      var inc = 50;
      while (start < line.length)
      {
        lineList.push(line.substr(start, inc));
        start += inc;
      }
      var result = lineList.join("\n");
      return result;
    }

    static function saveParts(stream : ByteArray, parts : Array) : void
    {
      stream.writeShort(parts.length);
      for each (var part in parts)
      {
        part.save(stream);
      }
    }

    static function saveWires(stream : ByteArray, wires : Array) : void
    {
      stream.writeShort(wires.length);
      for each (var wire in wires)
      {
        wire.save(stream);
      }
    }

    static function saveGoals(stream : ByteArray, goals : Array) : void
    {
      stream.writeByte(goals.length);
      for each (var goal in goals)
      {
        goal.save(stream);
      }
    }

    static function saveStencils(stream : ByteArray, stencils : Array) : void
    {
      stream.writeByte(stencils.length);
      var i = 0;
      for (; i < stencils.length; ++i)
      {
        stencils[i].saveStencil(stream);
      }
    }

    public static function savePoint(stream : ByteArray, pos : Point) : void
    {
      stream.writeByte(pos.x);
      stream.writeByte(pos.y);
    }

    static var CURRENT_VERSION = 2;
  }
}
