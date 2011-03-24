package logic
{
  import lib.Point;
  import ui.TrackView;

  public class Track
  {
    public function Track(newSprite : TrackView, newPos : Point,
                          newParent : Part) : void
    {
      sprite = newSprite;
      pos = newPos.clone();
      parents = [newParent];
      sprite.update(pos, getDir(), false);
    }

    public function addParent(newParent : Part) : void
    {
      var index = parents.indexOf(newParent);
      if (index == -1)
      {
        parents.push(newParent);
        sprite.update(pos, getDir(), false);
      }
    }

    public function removeParent(oldParent : Part) : void
    {
      var index = parents.indexOf(oldParent);
      if (index != -1)
      {
        parents.splice(index, 1);
      }
      if (parents.length == 0)
      {
        sprite.destroy();
      }
      else
      {
        sprite.update(pos, getDir(), false);
      }
    }

    public function update() : void
    {
      sprite.update(pos, getDir(), true);
    }

    public function getParents() : Array
    {
      return parents;
    }

    function getDir() : Dir
    {
      var result = null;
      for each (var parent in parents)
      {
        if (parent.isPowered() && result == null)
        {
          result = parent.getDir();
        }
        else if (parent.isPowered())
        {
          result = null;
          break;
        }
      }
      return result;
    }

    var sprite : TrackView;
    var pos : Point;
    var parents : Array;
  }
}
