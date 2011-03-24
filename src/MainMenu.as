package
{
  import flash.display.DisplayObjectContainer;
  import flash.events.Event;
  import flash.net.navigateToURL;
  import flash.net.URLRequest;
  import lib.Point;
  import lib.ui.ButtonList;
  import lib.ui.Keyboard;
  import ui.Sound;

  public class MainMenu implements MainState
  {
    public function MainMenu(newParent : DisplayObjectContainer,
                             newSettings : GameSettings,
                             newBeginGame : Function,
                             newKeyboard : lib.ui.Keyboard) : void
    {
      parent = newParent;
      keyboard = newKeyboard;
      menu = new MainMenuClip();
      parent.addChild(menu);
      var buttonArray = [menu.start.playGame,
                         menu.start.sandbox,
                         menu.start.playSave,
                         menu.start.editor,
                         menu.start.editorPaste,
                         menu.start.credits,
                         menu.start.community,
                         menu.paste.loadGame,
                         menu.paste.back,
                         menu.credits.back];
      buttons = new lib.ui.ButtonList(buttonArray);
      buttons.setActions(click, buttons.frameOver, buttons.frameOut);

      var glowArray = [menu.start.mute, menu.start.compLink];
      glowButtons = new lib.ui.ButtonList(glowArray);
      glowButtons.setActions(clickGlow, glowButtons.glowOver,
                             glowButtons.glowOut);

      menu.start.playGame.barText.text = "Play Campaign";
      menu.start.sandbox.barText.text = "Sandbox Mode";
      menu.start.playSave.barText.text = "Load Map";
      menu.start.editor.barText.text = "Edit New Map";
      menu.start.editorPaste.barText.text = "Edit Save";
      menu.start.credits.barText.text = "Credits";
      menu.start.community.barText.text = "Community";
      if (menu.start.moreGames != null)
      {
        menu.start.moreGames.barText.text = "More Games";
      }
      menu.paste.loadGame.barText.text = "Load";
      menu.paste.back.barText.text = "Back";
      menu.credits.back.barText.text = "Back";

      settings = newSettings;
      settings.reset(new Point(25, 25));
      beginGame = newBeginGame;

      menu.start.visible = true;
      menu.paste.visible = false;
      menu.credits.visible = false;

      menu.addEventListener(Event.ENTER_FRAME, moveArrows);

      levelMenu = new LevelMenu(parent, settings, beginGame, clearLevelMenu,
                                changeIsland, keyboard);

      if (Sound.isMute())
      {
        menu.start.mute.gotoAndStop(2);
      }
      else
      {
        menu.start.mute.gotoAndStop(1);
      }
    }

    public function cleanup() : void
    {
      levelMenu.cleanup();
      menu.removeEventListener(Event.ENTER_FRAME, moveArrows);
      glowButtons.cleanup();
      buttons.cleanup();
      menu.parent.removeChild(menu);
    }

    function moveArrows(event : Event) : void
    {
      if (menu.start.arrows.y <= -600)
      {
        menu.start.arrows.y = 0;
      }
      menu.start.arrows.y -= 0.5;
    }

    function clearLevelMenu() : void
    {
      levelMenu.cleanup();
      levelMenu = new LevelMenu(parent, settings, beginGame, clearLevelMenu,
                                changeIsland, keyboard);
    }

    function changeIsland() : void
    {
      clearLevelMenu();
      selectLevel();
    }

    function selectLevel() : void
    {
      settings.clearEditor();
      if (Campaign.island == Campaign.TUTORIAL_ISLAND)
      {
        levelMenu.startTutorial();
      }
      else
      {
        levelMenu.startMain();
      }
    }

    static var PLAY_GAME = 0;
    static var SANDBOX = 1;
    static var PLAY_SAVE = 2;
    static var EDITOR = 3;
    static var EDITOR_PASTE = 4;
    static var CREDITS = 5;
    static var COMMUNITY = 6;
    static var PASTE_LOAD = 7;
    static var PASTE_BACK = 8;
    static var CREDITS_BACK = 9;

    function click(choice : int) : void
    {
      Sound.play(Sound.SELECT);
      if (choice == PLAY_GAME)
      {
        selectLevel();
      }
      else if (choice == SANDBOX)
      {
        Campaign.parse(settings, "sandbox");
        beginGame();
      }
      else if (choice == PLAY_SAVE)
      {
        settings.clearEditor();
        menu.start.visible = false;
        menu.paste.visible = true;
        menu.stage.focus = menu.paste.code;
      }
      else if (choice == EDITOR)
      {
        settings.setEditor();
        beginGame();
      }
      else if (choice == EDITOR_PASTE)
      {
        settings.setEditor();
        menu.start.visible = false;
        menu.paste.visible = true;
        menu.stage.focus = menu.paste.code;
      }
      else if (choice == CREDITS)
      {
        menu.start.visible = false;
        menu.credits.visible = true;
      }
      else if (choice == COMMUNITY)
      {
        navigateToURL(new URLRequest("http://groups.google.com/group/tile-factory"));
      }
      else if (choice == PASTE_LOAD)
      {
        settings.setMap(menu.paste.code.text, SaveLoad.LOAD_ALL);
        beginGame();
      }
      else if (choice == PASTE_BACK)
      {
        menu.start.visible = true;
        menu.paste.visible = false;
      }
      else if (choice == CREDITS_BACK)
      {
        menu.start.visible = true;
        menu.credits.visible = false;
      }
    }

    function clickGlow(choice : int) : void
    {
      if (choice == 0)
      {
        Sound.toggleMute();
        if (menu.start.mute.currentFrame == 1)
        {
          menu.start.mute.gotoAndStop(2);
        }
        else
        {
          menu.start.mute.gotoAndStop(1);
        }
        Campaign.save();
      }
      else if (choice == 1)
      {
        navigateToURL(new URLRequest("http://jayisgames.com/cgdc8"));
      }
      Sound.play(Sound.SELECT);
    }

    var parent : DisplayObjectContainer;
    var keyboard : lib.ui.Keyboard;
    var menu : MainMenuClip;
    var buttons : lib.ui.ButtonList;
    var glowButtons : lib.ui.ButtonList;
    var settings : GameSettings;
    var beginGame : Function;
    var levelMenu : LevelMenu;
  }
}
