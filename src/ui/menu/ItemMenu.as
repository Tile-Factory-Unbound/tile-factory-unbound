package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import lib.ui.ButtonList;
  import logic.ButtonStatus;
  import logic.Part;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.Sound;
  import ui.StencilButtons;
  import ui.TabList;

  public class ItemMenu extends TabMenu
  {
    public function ItemMenu(parent : DisplayObjectContainer,
                             newSetMenu : Function,
                             newGoalPlace : GoalPlace) : void
    {
      goalPlace = newGoalPlace;
      clip = new ItemMenuClip();
      super(parent, clip, newSetMenu, TabList.ITEM_MENU);
      buttons = new ButtonList([clip.tile, clip.solvent, clip.glue,
                                clip.triangle, clip.rectangle,
                                clip.smallCircle, clip.circle, clip.bigCircle,
                                clip.white, clip.cyan, clip.magenta,
                                clip.yellow, clip.black]);
      buttons.setActions(click, buttons.glowOver, buttons.glowOut);
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

    public function setModel(newPartPlace : ui.PartPlace,
                             isEditor : Boolean,
                             buttonStatus : ButtonStatus,
                             stencilColors : Array) : void
    {
      partPlace = newPartPlace;
      if (! isEditor)
      {
        var hasButtons = false;
        var userButtons = [clip.tile, clip.solvent, clip.glue,
                           clip.triangle, clip.rectangle,
                           clip.smallCircle, clip.circle, clip.bigCircle,
                           clip.white, clip.cyan, clip.magenta,
                           clip.yellow, clip.black];
        var i = 0;
        for (; i < userButtons.length; ++i)
        {
          if (! buttonStatus.getStatus(i + Part.TILE))
          {
            userButtons[i].visible = false;
          }
          else
          {
            hasButtons = true;
          }
        }
        if (! hasButtons)
        {
          clip.visible = false;
        }
      }
      stencils = new StencilButtons([clip.triangle, clip.rectangle,
                                     clip.smallCircle, clip.circle,
                                     clip.bigCircle], stencilColors);
    }

    function click(choice : int) : void
    {
      partPlace.setPart(choice + Part.TILE);
      setMenu(TabList.PLACE_MENU);
      Sound.play(Sound.SELECT);
    }

    override public function show() : void
    {
      goalPlace.hide();
      super.show();
      stencils.reset();
    }

    override public function hide() : void
    {
      goalPlace.show();
      super.hide();
    }

    var clip : ItemMenuClip;
    var buttons : lib.ui.ButtonList;
    var goalPlace : ui.GoalPlace;
    var partPlace : ui.PartPlace;
    var stencils : StencilButtons;
  }
}
