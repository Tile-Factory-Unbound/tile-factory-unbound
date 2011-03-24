package logic
{
  import lib.ChangeList;
  import lib.Point;
  import lib.Util;

  import logic.change.ChangeWorld;

  public class Group
  {
    public function Group(founder : Item) : void
    {
      isForced = false;
      force = Dir.east;
      members = new Array();
      members.push(founder);
    }

    public function spawn(founder : Item) : Group
    {
      var result = new Group(founder);
      result.isForced = isForced;
      result.force = force;
      removeMember(founder);
      return result;
    }

    public function removeMember(oldItem : Item) : void
    {
      var index = members.indexOf(oldItem);
      if (index != -1)
      {
        members.splice(index, 1);
      }
    }

    public function mergeFrom(other : Group, changes : ChangeList) : void
    {
      for each (var member in other.members)
      {
        member.changeGroup(this);
        members.push(member);
      }
      other.members = [];
      if (! isForced)
      {
        force = other.force;
        isForced = other.isForced;
      }
      else if (other.isForced && other.force != force)
      {
//        trace("Merge Jam");
        changes.add(Util.makeChange(ChangeWorld.itemBlocked, Item.JAM,
                                    members[0].getPos().clone()));
      }
    }

    public function addForce(dir : Dir, changes : ChangeList) : void
    {
      if (! isForced || force == dir)
      {
        force = dir;
        isForced = true;
      }
      else
      {
//        trace("Item Jam");
        changes.add(Util.makeChange(ChangeWorld.itemBlocked, Item.JAM,
                                    members[0].getPos().clone()));
      }
    }

    public function hasForce() : Boolean
    {
      return isForced;
    }

    public function getForce() : Dir
    {
      return force;
    }

    public function clearForce() : void
    {
      isForced = false;
    }

    public function isGlued() : Boolean
    {
      return members.length > 1;
    }

    public function getSize() : int
    {
      return members.length;
    }

    public function getMembers() : Array
    {
      return members.slice();
    }

    var isForced : Boolean;
    var force : Dir;
    var members : Array;
  }
}
