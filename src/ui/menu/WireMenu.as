package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import flash.text.TextField;
  import logic.ButtonStatus;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.TabList;
  import ui.WireParent;
  import ui.WirePlace;

  public class WireMenu extends TabMenu
  {
    public function WireMenu(parent : DisplayObjectContainer,
                             setMenu : Function,
                             newWirePlace : WirePlace,
                             newWireParent : WireParent,
                             newGoalPlace : GoalPlace) : void
    {
      clip = new WireMenuClip();
      wirePlace = newWirePlace;
      wireParent = newWireParent;
      goalPlace = newGoalPlace;
      super(parent, clip, setMenu, TabList.WIRE_MENU);
    }

    public function setModel(newPartPlace : PartPlace,
                             buttonStatus : ButtonStatus) : void
    {
      partPlace = newPartPlace;
      if (! buttonStatus.getStatus(ButtonStatus.WIRE_BUTTON))
      {
        clip.visible = false;
      }
    }

    override public function show() : void
    {
      super.show();
      wirePlace.show();
      wireParent.show();
      partPlace.hide();
      goalPlace.hide();
    }

    override public function hide() : void
    {
      super.hide();
      wirePlace.hide();
      wireParent.hide();
      if (partPlace != null)
      {
        partPlace.show();
      }
      goalPlace.show();
    }

    public function getWireText() : TextField
    {
      return clip.wireText;
    }

    var clip : WireMenuClip;
    var wirePlace : WirePlace;
    var wireParent : WireParent;
    var partPlace : PartPlace;
    var goalPlace : GoalPlace;
  }
}
