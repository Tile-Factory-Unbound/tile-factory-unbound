package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import flash.events.MouseEvent;
  import lib.ui.ButtonList;
  import lib.ui.MenuList;
  import lib.ui.MenuRoot;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.Sound;

  public class PlaceMenu extends MenuRoot
  {
    public function PlaceMenu(parent : DisplayObjectContainer,
                              newGoalPlace : GoalPlace) : void
    {
      clip = new PlaceMenuClip();
      goalPlace = newGoalPlace;
      super(parent, clip, false, false);
      buttons = new ButtonList([clip.counter, clip.power, clip.clockwise,
                                clip.lock, clip.trash]);
      buttons.setActions(click, buttons.glowOver, buttons.glowOut);
      clip.addEventListener(MouseEvent.MOUSE_MOVE, move);
    }

    public function setModel(newPartPlace : PartPlace) : void
    {
      partPlace = newPartPlace;
    }

    override public function cleanup() : void
    {
      clip.removeEventListener(MouseEvent.MOUSE_MOVE, move);
      buttons.cleanup();
      super.cleanup();
    }

    override public function resize() : void
    {
      Screen.centerX(clip, null);
      Screen.bottom(clip, null);
    }

    override public function show() : void
    {
      super.show();
      clip.parent.setChildIndex(clip, clip.parent.numChildren - 1);
      goalPlace.hide();
    }

    override public function hide() : void
    {
      super.hide();
      goalPlace.show();
    }

    static var COUNTER = 0;
    static var POWER = 1;
    static var CLOCKWISE = 2;
    static var LOCK = 3;
    static var TRASH = 4;

    function click(choice : int) : void
    {
      if (choice == COUNTER)
      {
        partPlace.counter();
      }
      else if (choice == POWER)
      {
        partPlace.togglePower();
      }
      else if (choice == CLOCKWISE)
      {
        partPlace.clockwise();
      }
      else if (choice == LOCK)
      {
        partPlace.lock();
      }
      else if (choice == TRASH)
      {
        partPlace.returnToMenu();
        partPlace.hide();
        partPlace.show();
      }
      Sound.play(Sound.SELECT);
    }

    function move(event : MouseEvent) : void
    {
      partPlace.hoverMenu(event.stageX, event.stageY);
    }

    var clip : PlaceMenuClip;
    var buttons : lib.ui.ButtonList;
    var goalPlace : ui.GoalPlace;
    var partPlace : ui.PartPlace;
  }
}
