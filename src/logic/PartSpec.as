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
    }

    public function clone() : PartSpec
    {
      var result = new PartSpec(type, pos, dir, power);
      result.fixed = fixed;
      return result;
    }

    public function save(stream : ByteArray) : void
    {
      stream.writeByte(type);
      SaveLoad.savePoint(stream, pos);
      var dirPower = dir.toIndex();
      if (power)
      {
        dirPower = (dirPower | 0x4);
      }
      if (fixed)
      {
        dirPower = (dirPower | 0x8);
      }
      stream.writeByte(dirPower);
    }

    public var type : int;
    public var pos : Point;
    public var dir : Dir;
    public var power : Boolean;
    public var fixed : Boolean;
  }
}
