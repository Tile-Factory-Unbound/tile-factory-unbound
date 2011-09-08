package logic
{
  import flash.utils.ByteArray;

  import lib.Point;

  public class PartSpec
  {
    public function PartSpec(newType : int, newPos : Point, newDir : Dir,
                             newPower : Boolean) : void
    {
      type = newType;
      pos = newPos;
      dir = newDir;
      power = newPower;
      fixed = false;
      locked = false;
    }

    public function clone() : PartSpec
    {
      var result = new PartSpec(type, pos, dir, power);
      result.fixed = fixed;
      result.locked = locked;
      return result;
    }

    public function save(stream : ByteArray) : void
    {
      stream.writeByte(type);
      SaveLoad.savePoint(stream, pos);
      var dirPower = dir.toIndex();
      if (power)
      {
        dirPower = (dirPower | 0x04);
      }
      if (fixed || locked)
      {
        dirPower = (dirPower | 0x08);
      }
      if (locked)
      {
        dirPower = (dirPower | 0x10);
      }
      stream.writeByte(dirPower);
    }

    public var type : int;
    public var pos : Point;
    public var dir : Dir;
    public var power : Boolean;
    public var fixed : Boolean;
    public var locked : Boolean;
  }
}
