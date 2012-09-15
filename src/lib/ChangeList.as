// ChangeList.as
//
// This is a list of functions which will be executed on the next
// frame. Anything which changes non-local game state should be
// implemented with a change function which is then pushed onto the
// list.

package lib
{
  // Model and View must be defined in the client's namespace to use this class
  import logic.Model;
  import ui.View;

  public class ChangeList
  {
    public function ChangeList() : void
    {
      changes = new DList();
    }

    public function add(newChange : Function) : void
    {
      changes.pushBack(newChange);
    }

    public function getSize() : int
    {
      return changes.size();
    }

    public function execute(model : logic.Model, view : ui.View) : void
    {
      while (! changes.isEmpty())
      {
        var current = changes.front();
        changes.popFront();
        current.call(null, model, view);
      }
    }

    var changes : DList;
  }
}
