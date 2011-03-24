package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import lib.ui.ButtonList;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.Sound;
  import ui.TabList;

  public class GoalMenu extends TabMenu
  {
    public function GoalMenu(parent : DisplayObjectContainer,
                             newGoalPlace : GoalPlace,
                             setMenu : Function) : void
    {
      goalPlace = newGoalPlace;
      clip = new GoalMenuClip();
      super(parent, clip, setMenu, TabList.GOAL_MENU);
      buttons = new ButtonList([clip.p.deleteButton,
                                clip.addButton]);
      buttons.setActions(click, buttons.frameOver, buttons.frameOut);

      clip.p.deleteButton.barText.text = "Delete Goal";
      clip.addButton.barText.text = "Add Goal";

      arrowButtons = new ButtonList([clip.p.moveNorth,
                                     clip.p.expandNorth,
                                     clip.p.contractNorth,
                                     clip.p.moveSouth,
                                     clip.p.expandSouth,
                                     clip.p.contractSouth,
                                     clip.p.moveEast,
                                     clip.p.expandEast,
                                     clip.p.contractEast,
                                     clip.p.moveWest,
                                     clip.p.expandWest,
                                     clip.p.contractWest]);
      arrowButtons.setActions(arrowClick, arrowButtons.glowOver,
                              arrowButtons.glowOut);
    }

    override public function cleanup() : void
    {
      buttons.cleanup();
      arrowButtons.cleanup();
      super.cleanup();
    }

    public function setModel(newPartPlace : PartPlace) : void
    {
      partPlace = newPartPlace;
    }

    override public function show() : void
    {
      super.show();
      if (goalPlace.hasGoal())
      {
        clip.p.visible = true;
        clip.message.visible = false;
        clip.addButton.visible = false;
      }
      else
      {
        clip.p.visible = false;
        clip.message.visible = true;
        clip.addButton.visible = true;
      }
      partPlace.hide();
      goalPlace.toggleGoalHeight();
      goalPlace.selectGoals();
    }

    override public function hide() : void
    {
      super.hide();
      if (partPlace != null)
      {
        partPlace.show();
      }
      goalPlace.toggleGoalHeight();
    }

    function click(choice : int) : void
    {
      if (choice == 0)
      {
        goalPlace.deleteGoal();
        goalPlace.clearGoal();
        show();
      }
      else
      {
        goalPlace.addGoal();
      }
      Sound.play(Sound.SELECT);
    }

    function arrowClick(choice : int) : void
    {
      var op = choice % 3;
      var dir = Dir.dirs[Math.floor(choice / 3)];
      goalPlace.modifyGoal(op, dir);
      Sound.play(Sound.SELECT);
    }

    var goalPlace : ui.GoalPlace;
    var clip : GoalMenuClip;
    var buttons : lib.ui.ButtonList;
    var arrowButtons : lib.ui.ButtonList;
    var partPlace : ui.PartPlace;
  }
}
