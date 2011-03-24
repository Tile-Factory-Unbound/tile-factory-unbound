package ui
{
  import lib.ui.Image;

  public class Anim
  {
    public function Anim(newStart : int, newEnd : int) : void
    {
      start = newStart;
      end = newEnd;

      image = null;
      frame = start;
      paused = true;
      cycle = false;
    }

    public function clone() : Anim
    {
      return new Anim(start, end);
    }

    public function play() : void
    {
      frame = start;
      paused = false;
    }

    public var start : int;
    public var end : int;

    public var image : Image;
    public var frame : int;
    public var paused : Boolean;
    public var cycle : Boolean;
  }
}
