package logic
{
  public class ButtonStatus
  {
    public function ButtonStatus() : void
    {
      buttons = 0x10003fff
    }

    // Returns true if button is enabled.
    public function getStatus(index : int) : Boolean
    {
      return (((buttons >> index) & 0x1) == 1);
    }

    public function toggleStatus(index : int) : void
    {
      buttons = ((0x1 << index) ^ buttons);
    }

    public function getAllStatus() : int
    {
      return buttons;
    }

    public function setAllStatus(newStatus : int) : void
    {
      buttons = newStatus;
    }

    var buttons : int;

    public static var WIRE_BUTTON = 28;
  }
}
