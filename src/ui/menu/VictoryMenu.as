package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import lib.ui.ButtonList;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.Sound;
  import ui.TabList;

  public class VictoryMenu extends TabMenu
  {
    public function VictoryMenu(parent : DisplayObjectContainer,
                                setMenu : Function,
                                newGoalPlace : GoalPlace) : void
    {
      clip = new VictoryMenuClip();
      goalPlace = newGoalPlace;
      super(parent, clip, setMenu, TabList.VICTORY_MENU);
      buttons = new ButtonList([clip.nextButton]);
      buttons.setActions(click, buttons.frameOver, buttons.frameOut);

      clip.nextButton.barText.text = "Complete";
    }

    public function setModel(newSettings : GameSettings,
                             newEndGame : Function,
                             newPartPlace : PartPlace,
                             newCountParts : Function,
                             newCountSteps : Function,
                             newCountCreated : Function,
                             newCountBroken : Function) : void
    {
      settings = newSettings;
      endGame = newEndGame;
      partPlace = newPartPlace;
      countParts = newCountParts;
      countSteps = newCountSteps;
      countCreated = newCountCreated;
      countBroken = newCountBroken;
    }

    override public function cleanup() : void
    {
      buttons.cleanup();
      super.cleanup();
    }

    override public function show() : void
    {
      super.show();
      clip.visible = true;
      goalPlace.hide();
      partPlace.hide();
      var time = countSteps();
      var minutes = Math.floor(time / 60);
      var seconds = time % 60;
      var timeText = minutes + ":";
      if (seconds < 10)
      {
        timeText += "0";
      }
      timeText += seconds;
      clip.time.text = timeText;
      clip.parts.text = countParts();
      clip.items.text = countCreated();
      clip.broken.text = countBroken();
      if (settings.getId() == null)
      {
        clip.nextButton.visible = false;
      }
      else
      {
        clip.nextButton.visible = true;
      }
    }

    override public function hide() : void
    {
      super.hide();
      clip.visible = false;
      goalPlace.show();
      if (partPlace != null)
      {
        partPlace.show();
      }
    }

    function click(choice : int) : void
    {
      Sound.play(Sound.SELECT);
      endGame(Game.WIN_GAME);
    }

    var clip : VictoryMenuClip;
    var buttons : lib.ui.ButtonList;
    var settings : GameSettings;
    var endGame : Function;
    var goalPlace : GoalPlace;
    var partPlace : PartPlace;
    var countParts : Function;
    var countSteps : Function;
    var countCreated : Function;
    var countBroken : Function;
  }
}
