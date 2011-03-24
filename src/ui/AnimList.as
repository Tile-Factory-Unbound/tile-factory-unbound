package ui
{
  import lib.DList;
  import lib.DIterator;

  public class AnimList
  {
    public function AnimList() : void
    {
      anims = new DList();
    }

    public function add(newAnim : Anim) : void
    {
      anims.pushBack(newAnim);
    }

    public function remove(oldAnim : Anim) : void
    {
      anims.remove(oldAnim);
    }

    public function enterFrame() : void
    {
      var pos : DIterator = anims.frontIterator();
      for (; pos.isValid(); pos.increment())
      {
        var current : Anim = pos.get();
        if (! current.paused)
        {
          if (current.frame == current.end)
          {
            current.frame = current.start;
            current.paused = ! current.cycle;
          }
          else
          {
            current.frame += 1;
          }
          current.image.setFrame(current.frame);
        }
      }
    }

    var anims : DList;
  }
}
