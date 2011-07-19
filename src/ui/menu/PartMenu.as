package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import lib.ui.ButtonList;
  import logic.ButtonStatus;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.Sound;
  import ui.TabList;

  public class PartMenu extends TabMenu
  {
    public function PartMenu(parent : DisplayObjectContainer,
                             newSetMenu : Function,
                             newGoalPlace : GoalPlace) : void
    {
      goalPlace = newGoalPlace;
      clip = new PartMenuClip();
      super(parent, clip, newSetMenu, TabList.PART_MENU);
      buttons = new ButtonList([clip.all, clip.some, clip.none,
                                clip.mem, clip.setButton, clip.clear,
                                clip.conveyer, clip.barrier,
                                clip.rotater, clip.sensor,
                                clip.sprayer, clip.mixer,
                                clip.copier]);
      buttons.setActions(click, mouseOver, mouseOut);
    }

    override public function cleanup() : void
    {
      buttons.cleanup();
      super.cleanup();
    }

    public function setModel(newPartPlace : ui.PartPlace,
                             isEditor : Boolean,
                             buttonStatus : ButtonStatus,
                             newTip : ToolTipClip) : void
    {
      partPlace = newPartPlace;
      tip = newTip;
      if (! isEditor)
      {
        var userButtons = [clip.all, clip.some, clip.none,
                           clip.mem, clip.setButton, clip.clear,
                           clip.conveyer, clip.barrier,
                           clip.rotater, clip.sensor,
                           clip.sprayer, clip.mixer,
                           clip.copier];
        var i = 0;
        for (; i < userButtons.length; ++i)
        {
          if (! buttonStatus.getStatus(i))
          {
            userButtons[i].visible = false;
          }
        }
      }
    }

    function click(choice : int) : void
    {
      partPlace.setPart(choice);
      setMenu(TabList.PLACE_MENU);
      Sound.play(Sound.SELECT);
    }

    function mouseOver(index : int) : void
    {
      buttons.glowOver(index);
      tip.x = buttons.get(index).x + clip.x;
      if (tip.x < tip.width / 2 + 10)
      {
        tip.x = tip.width / 2 + 10 + clip.x;
      }
      if (tip.x > Main.WIDTH - tip.width / 2 - 10)
      {
        tip.x = Main.WIDTH - tip.width / 2 - 10 + clip.x;
      }
      tip.y = buttons.get(index).y + clip.y;
      tip.visible = true;
      tip.barText.text = partTitles[index];
      tip.blurb.text = partBlurbs[index];
    }

    function mouseOut(index : int) : void
    {
      buttons.glowOut(index);
      tip.visible = false;
    }

    override public function show() : void
    {
      goalPlace.hide();
      super.show();
    }

    override public function hide() : void
    {
      goalPlace.show();
      super.hide();
    }

    var clip : PartMenuClip;
    var buttons : lib.ui.ButtonList;
    var goalPlace : ui.GoalPlace;
    var partPlace : ui.PartPlace;
    var tip : ToolTipClip;

    static var partTitles = ["All", "Some", "None", "Memory", "Set", "Clear",
                             "Conveyer", "Barrier", "Rotater", "Sensor",
                             "Sprayer", "Mixer", "Copier"];
    static var partBlurbs = ["Powered only when ALL\ninput wires are on",
                             "Powered when ANY\ninput wires are on",
                             "Powered when NO\ninput wires are on",
                             "Changes power after\nwaiting one second",
                             "Turns ON adjacent\nmemory when powered",
                             "Turns OFF adjacent\nmemory when powered",
                             "Pushes tiles in\na straight line",
                             "Stops conveyer\ntracks",
                             "Rotates tiles\nand stencils",
                             "Turns on when a\ntile moves over it",
                             "Sprays paint, stencils, glue\nand solvent onto tiles",
                             "Mixes paint together\nto make new colors",
                             "Duplicates any item"];
  }
}
