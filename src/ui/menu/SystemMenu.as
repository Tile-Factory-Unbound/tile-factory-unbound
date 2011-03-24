package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import flash.events.Event;
  import flash.system.System;
  import lib.ui.ButtonList;
  import ui.Sound;

  public class SystemMenu
  {
    public function SystemMenu(parent : DisplayObjectContainer) : void
    {
      top = new TopMenuClip();
      parent.addChild(top);
      if (Sound.isMute())
      {
        top.muteButton.gotoAndStop(2);
      }
      system = new SystemMenuClip();
      parent.addChild(system);
      system.visible = false;
      system.resumeButton.barText.text = "Resume";
      system.saveButton.barText.text = "Save";
      system.soundButton.barText.text = "Toggle Music";
      system.skipButton.barText.text = "Skip Level";
      system.restartButton.barText.text = "Restart Level";
      system.quitButton.barText.text = "Quit to Menu";
      save = new SaveMenuClip();
      parent.addChild(save);
      save.visible = false;
      save.copyButton.barText.text = "Copy";
      save.backButton.barText.text = "Back";
      buttonsTop = new ButtonList([top.muteButton, top.menuButton]);
      buttonsTop.setActions(clickTop, buttonsTop.glowOver, buttonsTop.glowOut);
      buttonsSystem = new ButtonList([system.resumeButton, system.saveButton,
                                      system.soundButton, system.skipButton,
                                      system.restartButton,
                                      system.quitButton, save.copyButton,
                                      save.backButton]);
      buttonsSystem.setActions(clickSystem, buttonsSystem.frameOver,
                               buttonsSystem.frameOut);
    }

    public function cleanup() : void
    {
      system.removeEventListener(Event.ENTER_FRAME, enterFrame);
      buttonsSystem.cleanup();
      buttonsTop.cleanup();
      top.parent.removeChild(top);
      system.parent.removeChild(system);
    }

    public function setModel(newEndGame : Function,
                             newSaveMap : Function,
                             newSettings : GameSettings) : void
    {
      endGame = newEndGame;
      saveMap = newSaveMap;
      settings = newSettings;
    }

    static var MUTE = 0;
    static var MENU = 1;

    function clickTop(choice : int) : void
    {
      if (choice == MUTE)
      {
        toggleSound();
      }
      else if (choice == MENU)
      {
        if (settings.getId() != null)
        {
          Campaign.saveLevel(settings.getId(), saveMap());
        }
        show();
      }
      Sound.play(Sound.SELECT);
    }

    static var RESUME = 0;
    static var SAVE = 1;
    static var SOUND = 2;
    static var SKIP = 3;
    static var RESTART = 4;
    static var QUIT = 5;
    static var COPY = 6;
    static var BACK = 7;

    function clickSystem(choice : int) : void
    {
      if (choice == RESUME)
      {
        hide();
      }
      else if (choice == SAVE)
      {
        save.visible = true;
        save.code.text = saveMap();
        save.stage.focus = save.code;
        save.code.setSelection(0, save.code.length);
      }
      else if (choice == SOUND)
      {
        Sound.toggleMusic();
        Campaign.save();
//        toggleSound();
      }
      else if (choice == SKIP)
      {
        endGame(Game.SKIP_GAME);
      }
      else if (choice == RESTART)
      {
        if (settings.getId() != null)
        {
          Campaign.levelSaves[settings.getId()] = null;
        }
        endGame(Game.RESTART_GAME);
      }
      else if (choice == QUIT)
      {
        endGame(Game.END_GAME);
      }
      else if (choice == COPY)
      {
        flash.system.System.setClipboard(save.code.text);
      }
      else if (choice == BACK)
      {
        save.visible = false;
      }
      Sound.play(Sound.SELECT);
    }

    function toggleSound() : void
    {
      if (top.muteButton.currentFrame == 1)
      {
        top.muteButton.gotoAndStop(2);
      }
      else
      {
        top.muteButton.gotoAndStop(1);
      }
      Sound.toggleMute();
      Campaign.save();
    }

    function enterFrame(event : Event) : void
    {
      if (system.arrows.y <= -600)
      {
        system.arrows.y = 0;
      }
      system.arrows.y -= 0.5;
    }

    function show() : void
    {
      system.visible = true;
      system.addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    function hide() : void
    {
      system.visible = false;
      system.removeEventListener(Event.ENTER_FRAME, enterFrame);
    }

    var top : TopMenuClip;
    var system : SystemMenuClip;
    var save : SaveMenuClip;
    var buttonsTop : lib.ui.ButtonList;
    var buttonsSystem : lib.ui.ButtonList;
    var endGame : Function;
    var saveMap : Function;
    var settings : GameSettings;
  }
}
