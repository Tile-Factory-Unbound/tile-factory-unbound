package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import flash.display.InteractiveObject;
  import flash.geom.ColorTransform;
  import lib.ChangeList;
  import lib.Util;
  import lib.ui.ButtonList;
  import logic.change.ChangeWorld;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.Sound;
  import ui.TabList;

  public class TestMenu
  {
    static var STOP = 0;
    static var PLAY = 1;
    static var FAST = 2;
    static var PAUSE = 3;
    static var STEP = 4;
    static var TURBO = 5;

    public function TestMenu(parent : DisplayObjectContainer,
                             newGoalPlace : GoalPlace,
                             newTabs : TabList) : void
    {
      clip = new PlayMenuClip();
      parent.addChild(clip);
      goalPlace = newGoalPlace;
      tabs = newTabs;
      setState(STOP);
      buttons = new ButtonList([clip.stopButton, clip.playButton,
                                clip.fastButton, clip.pauseButton,
                                clip.stepButton, clip.turboButton]);
      buttons.setActions(click, buttons.glowOver, buttons.glowOut);
    }

    public function cleanup() : void
    {
      buttons.cleanup();
      clip.parent.removeChild(clip);
    }

    public function resize() : void
    {
      Screen.stretchSquare(clip, 1.0, 2.0);
      Screen.right(clip, null);
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

    public function show() : void
    {
      clip.visible = true;
    }

    public function hide() : void
    {
      clip.visible = false;
    }

    function setState(newState : int) : void
    {
      state = newState;
      if (state == STOP)
      {
        activeButton(clip.stopButton);
        enableButtons([clip.playButton, clip.fastButton, clip.stepButton,
                       clip.turboButton]);
        disableButtons([clip.pauseButton]);
      }
      else if (state == PLAY)
      {
        activeButton(clip.playButton);
        enableButtons([clip.stopButton, clip.fastButton, clip.pauseButton,
                       clip.turboButton]);
        disableButtons([clip.stepButton]);
      }
      else if (state == FAST)
      {
        activeButton(clip.fastButton);
        enableButtons([clip.playButton, clip.stopButton, clip.pauseButton,
                       clip.turboButton]);
        disableButtons([clip.stepButton]);
      }
      else if (state == PAUSE)
      {
        activeButton(clip.pauseButton);
        enableButtons([clip.playButton, clip.stopButton, clip.fastButton,
                       clip.stepButton, clip.turboButton]);
      }
      else if (state == TURBO)
      {
        activeButton(clip.turboButton);
        enableButtons([clip.playButton, clip.stopButton, clip.pauseButton,
                       clip.fastButton]);
        disableButtons([clip.stepButton]);
      }
    }

    function activeButton(good : InteractiveObject) : void
    {
      for each (var bad in [clip.stopButton, clip.playButton, clip.fastButton,
                            clip.pauseButton, clip.stepButton,
                            clip.turboButton])
      {
        bad.transform.colorTransform = new ColorTransform(1.0, 1.0, 1.0, 1.0,
                                                          0, 0, 0, 0);
      }
      good.transform.colorTransform = new ColorTransform(0.6, 1.8, 0.6, 1.0,
                                                         0, 50, 0, 0);
      good.mouseEnabled = false;
      good.alpha = 1;
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

    function starting() : void
    {
      if (settings.getId() != null)
      {
        Campaign.saveLevel(settings.getId(), saveMap());
      }
      tabs.hide();
    }

    function stopping() : void
    {
      tabs.show();
    }

    function click(choice : int) : void
    {
      if (choice == STOP)
      {
        stopping();
        changes.add(Util.makeChange(ChangeWorld.togglePlay));
        setState(STOP);
      }
      else if (choice == PLAY)
      {
        if (state == STOP)
        {
          starting();
          changes.add(Util.makeChange(ChangeWorld.togglePlay));
        }
        else if (state == FAST || state == TURBO)
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
          starting();
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
          starting();
          changes.add(Util.makeChange(ChangeWorld.togglePlay));
          changes.add(Util.makeChange(ChangeWorld.pausePlay));
          setState(PAUSE);
        }
        changes.add(Util.makeChange(ChangeWorld.stepPlay));
      }
      else if (choice == TURBO)
      {
        if (state == STOP)
        {
          starting();
          changes.add(Util.makeChange(ChangeWorld.togglePlay));
        }
        if (state == PAUSE)
        {
          changes.add(Util.makeChange(ChangeWorld.resumePlay));
        }
        changes.add(Util.makeChange(ChangeWorld.turboPlay));
        setState(TURBO);
      }
      Sound.play(Sound.SELECT);
    }

    var clip : PlayMenuClip;
    var buttons : lib.ui.ButtonList;
    var changes : lib.ChangeList;
    var state : int;
    var goalPlace : GoalPlace;
    var partPlace : PartPlace;
    var settings : GameSettings;
    var saveMap : Function;
    var tabs : TabList;
  }
}
