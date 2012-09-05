package lib
{
  public class Actor
  {
    public function Actor(newSpeed : int, newDelay : int) : void
    {
      speed = newSpeed;
      if (speed < 1)
      {
        speed = 1;
      }
      delay = newDelay;
      if (delay < 1)
      {
        delay = 1;
      }
      speedCounter = 0;
    }

    public function cleanup() : void
    {
    }

    public function wait(count : int) : void
    {
      speedCounter -= delay * count;
    }

    public function enterFrame(changes : ChangeList) : void
    {
      speedCounter += speed;
      while (speedCounter > 0)
      {
        step(changes);
        speedCounter -= delay;
      }
    }

    protected function step(changes : lib.ChangeList) : void
    {
    }

    var speed : int;
    var delay : int;
    var speedCounter : int;
  }
}
