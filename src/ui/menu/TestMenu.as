package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import lib.ChangeList;
  import lib.Util;
  import lib.ui.ButtonList;
  import logic.change.ChangeWorld;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.Sound;
  import ui.TabList;

  public class TestMenu extends TabMenu
  {
    static var STOP = 0;
    static var PLAY = 1;
    static var FAST = 2;
    static var PAUSE = 3;
    static var STEP = 4;

    public function TestMenu(parent : DisplayObjectContainer,
                             setMenu : Function,
                             newGoalPlace : GoalPlace) : void
    {
      clip = new TestMenuClip();
      goalPlace = newGoalPlace;
      setState(STOP);
      super(parent, clip, setMenu, TabList.TEST_MENU);
      buttons = new ButtonList([clip.stopButton, clip.playButton,
                                clip.fastButton, clip.pauseButton,
                                clip.stepButton]);
      buttons.setActions(click, buttons.glowOver, buttons.glowOut);
    }

    override public function cleanup() : void
    {
      buttons.cleanup();
      super.cleanup();
    }

    public function setModel(newChanges : ChangeList,
                             newPartPlace : PartPlace,
                             newSettings : GameSettings,
                             newSaveMap : Function) : void
    {
      changes = newChanges;
      partPlace = newPartPlace;
      settings = newSettings;
      saveMap = newSaveMap;
    }

    override public function show() : void
    {
      super.show();
      goalPlace.hide();
      partPlace.hide();
      if (settings.getId() != null)
      {
        Campaign.saveLevel(settings.getId(), saveMap());
      }
    }

    override public function hide() : void
    {
      super.hide();
      if (state != STOP)
      {
        changes.add(Util.makeChange(ChangeWorld.togglePlay));
        setState(STOP);
      }
      goalPlace.show();
      if (partPlace != null)
      {
        partPlace.show();
      }
    }

    function setState(newState : int) : void
    {
      state = newState;
      clip.status.text = stateText[state];
      if (state == STOP)
      {
        enableButtons([clip.playButton, clip.fastButton, clip.stepButton]);
        disableButtons([clip.stopButton, clip.pauseButton]);
      }
      else if (state == PLAY)
      {
        enableButtons([clip.stopButton, clip.fastButton, clip.pauseButton]);
        disableButtons([clip.playButton, clip.stepButton]);
      }
      else if (state == FAST)
      {
        enableButtons([clip.playButton, clip.stopButton, clip.pauseButton]);
        disableButtons([clip.fastButton, clip.stepButton]);
      }
      else if (state == PAUSE)
      {
        enableButtons([clip.playButton, clip.stopButton,
                       clip.fastButton, clip.stepButton]);
        disableButtons([clip.pauseButton]);
      }
    }

    function enableButtons(good : Array) : void
    {
      for each (var current in good)
      {
        current.alpha = 1;
        current.mouseEnabled = true;
      }
    }

    function disableButtons(bad : Array) : void
    {
      for each (var current in bad)
      {
        current.alpha = 0.3;
        current.mouseEnabled = false;
      }
    }

    function click(choice : int) : void
    {
      if (choice == STOP)
      {
        changes.add(Util.makeChange(ChangeWorld.togglePlay));
        setState(STOP);
        setMenu(TabList.PART_MENU);
      }
      else if (choice == PLAY)
      {
        if (state == STOP)
        {
          changes.add(Util.makeChange(ChangeWorld.togglePlay));
        }
        else if (state == FAST)
        {
          changes.add(Util.makeChange(ChangeWorld.slowPlay));
        }
        else if (state == PAUSE)
        {
          changes.add(Util.makeChange(ChangeWorld.resumePlay));
        }
        setState(PLAY);
      }
      else if (choice == FAST)
      {
        if (state == STOP)
        {
          changes.add(Util.makeChange(ChangeWorld.togglePlay));
        }
        if (state == PAUSE)
        {
          changes.add(Util.makeChange(ChangeWorld.resumePlay));
        }
        changes.add(Util.makeChange(ChangeWorld.fastPlay));
        setState(FAST);
      }
      else if (choice == PAUSE)
      {
        changes.add(Util.makeChange(ChangeWorld.pausePlay));
        setState(PAUSE);
      }
      else if (choice == STEP)
      {
        if (state == STOP)
        {
          changes.add(Util.makeChange(ChangeWorld.togglePlay));
          changes.add(Util.makeChange(ChangeWorld.pausePlay));
          setState(PAUSE);
        }
        changes.add(Util.makeChange(ChangeWorld.stepPlay));
      }
      Sound.play(Sound.SELECT);
    }

    var clip : TestMenuClip;
    var buttons : lib.ui.ButtonList;
    var changes : lib.ChangeList;
    var state : int;
    var goalPlace : GoalPlace;
    var partPlace : PartPlace;
    var settings : GameSettings;
    var saveMap : Function;

    var stateText = ["Stopped", "Playing", "Fast", "Paused", "Error"];
  }
}
