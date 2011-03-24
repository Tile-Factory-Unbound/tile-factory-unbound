package ui
{
  public class Draw
  {
    static var MOVE = 0;
    static var LINE = 1;
    static var CURVE = 2;

    public function Draw(newX : Number, newY : Number,
                         newOp : int, ...newControl)
    {
      if (newControl.length == 2)
      {
        controlX = newControl[0];
        controlY = newControl[1];
      }
      x = newX;
      y = newY;
      op = newOp;
    }

    public var x : Number;
    public var y : Number;
    public var op : int;
    var controlX : Number;
    var controlY : Number;
  }
}
