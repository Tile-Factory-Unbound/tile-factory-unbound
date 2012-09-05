package lib
{
  public class ActorList
  {
    public function ActorList() : void
    {
      actors = new DList();
    }

    public function cleanup() : void
    {
      var pos : DIterator = actors.frontIterator();
      for (; pos.isValid(); pos.increment())
      {
        pos.get().cleanup();
      }
    }

    public function add(newActor : Actor) : void
    {
      actors.pushBack(newActor);
    }

    public function remove(oldActor : Actor) : void
    {
      actors.remove(oldActor);
    }

    public function enterFrame(changes : ChangeList) : void
    {
      var pos : DIterator = actors.frontIterator();
      for (; pos.isValid(); pos.increment())
      {
        pos.get().enterFrame(changes);
      }
    }

    var actors : DList;
  }
}
