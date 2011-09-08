package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import flash.filters.GlowFilter;
  import lib.ui.MenuList;
  import lib.ui.MenuRoot;
  import lib.ui.ButtonList;
  import logic.ButtonStatus;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.Sound;
  import ui.StencilButtons;
  import ui.TabList;

  public class ButtonMenu extends TabMenu
  {
    public function ButtonMenu(newParent : DisplayObjectContainer,
                               setMenu : Function,
                               newGoalPlace : GoalPlace) : void
    {
      goalPlace = newGoalPlace;
      clip = new ButtonMenuClip();
      super(newParent, clip, setMenu, TabList.BUTTON_MENU);
      buttonArray = [clip.all, clip.some, clip.none,
                     clip.mem, clip.setButton,
                     clip.clear,
                     clip.conveyer, clip.barrier,
                     clip.rotater, clip.flip, clip.invert,
                     clip.sensor,
                     clip.sprayer, clip.mixer,
                     clip.copier,
                     clip.tile, clip.solvent,
                     clip.glue,
                     clip.triangle, clip.rectangle,
                     clip.smallCircle, clip.circle,
                     clip.bigCircle,
                     clip.white, clip.cyan,
                     clip.magenta, clip.yellow,
                     clip.black, clip.wireButton];
      buttons = new ButtonList(buttonArray);
      buttons.setActions(click, null, null);

      clip.wireButton.barText.text = "Wires";
    }

    public function setModel(newStatus : logic.ButtonStatus,
                             newPartPlace : PartPlace,
                             stencilColors : Array) : void
    {
      status = newStatus;
      partPlace = newPartPlace;
      stencils = new StencilButtons([clip.triangle, clip.rectangle,
                                     clip.smallCircle, clip.circle,
                                     clip.bigCircle], stencilColors);
    }

    override public function cleanup() : void
    {
      if (stencils != null)
      {
        stencils.cleanup();
      }
      buttons.cleanup();
      super.cleanup();
    }

    override public function show() : void
    {
      super.show();
      var i = 0;
      for (; i < buttonArray.length; ++i)
      {
        updateStatus(i);
      }
      partPlace.hide();
      goalPlace.hide();
      stencils.reset();
    }

    override public function hide() : void
    {
      super.hide();
      if (partPlace != null)
      {
        partPlace.show();
      }
      goalPlace.show();
    }

    function updateStatus(index : int) : void
    {
      if (status.getStatus(index))
      {
        buttonArray[index].filters = [onGlow];
      }
      else
      {
        buttonArray[index].filters = [offGlow];
      }
    }

    function click(choice : int) : void
    {
      status.toggleStatus(choice);
      updateStatus(choice);
      Sound.play(Sound.SELECT);
    }

    var clip : ButtonMenuClip;
    var buttonArray : Array;
    var buttons : lib.ui.ButtonList;
    var status : logic.ButtonStatus;
    var partPlace : ui.PartPlace;
    var goalPlace : ui.GoalPlace;
    var stencils : StencilButtons;

    static var onGlow = new GlowFilter(0x00cc00, 1.0, 10, 10, 3, 3);
    static var offGlow = new GlowFilter(0xcc0000, 1.0, 10, 10, 3, 3);
  }
}
