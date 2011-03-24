package
{
  import flash.display.DisplayObjectContainer;
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.geom.ColorTransform;
  import lib.Point;
  import lib.ui.ButtonList;
  import lib.ui.ImageList;
  import lib.ui.Keyboard;
  import lib.ui.Window;
  import lib.ui.WindowBorder;
  import ui.ScrollMenu;
  import ui.Sound;

  public class LevelMenu
  {
    public function LevelMenu(newParent : DisplayObjectContainer,
                              newSettings : GameSettings,
                              newBeginGame : Function,
                              newReturnFunction : Function,
                              newChangeIsland : Function,
                              newKeyboard : Keyboard) : void
    {
      parent = newParent;
      settings = newSettings;
      beginGame = newBeginGame;
      returnFunction = newReturnFunction;
      changeIsland = newChangeIsland;
      keyboard = newKeyboard;
      images = new ImageList();
      newClips = [];
      frame = 0;
    }

    public function cleanup() : void
    {
      if (clip != null)
      {
        clip.removeEventListener(Event.ENTER_FRAME, enterFrame);
      }
      if (scrollMenu != null)
      {
        scrollMenu.cleanup();
      }
      if (bubble != null)
      {
        bubble.parent.removeChild(bubble);
      }
      if (backButtons != null)
      {
        backButtons.cleanup();
      }
      if (overlay != null)
      {
        overlay.parent.removeChild(overlay);
      }
      if (buttons != null)
      {
        buttons.cleanup();
      }
      if (window != null)
      {
        window.cleanup();
      }
      images.cleanup();
    }

    function resetWindow(backgroundSize : Point) : void
    {
      clip.addEventListener(Event.ENTER_FRAME, enterFrame);
      if (window != null)
      {
        window.cleanup();
      }
      window = new Window(parent, new Point(Main.WIDTH, Main.HEIGHT),
                          backgroundSize, 1, images, new WindowBorder(),
                          clip, 0);
      bubble = new FactoryBubbleClip();
      parent.addChild(bubble);
      bubble.visible = false;
      bubble.mouseEnabled = false;
      bubble.mouseChildren = false;
      scrollMenu = new ScrollMenu(parent, window, keyboard, false);
      window.setOffset(Campaign.islandPos);
    }

    public function startTutorial() : void
    {
      clip = new TutorialIslandClip();
      levelClips = [clip.bridge, clip.l0, clip.l1, clip.l2, clip.l3, clip.l4, clip.l5,
                    clip.l6, clip.l7, clip.l8, clip.l9, clip.l10, clip.l11,
                    clip.l12, clip.l13, clip.l14, clip.l15, clip.l16, clip.l17,
                    clip.l18, clip.l19, clip.l20, clip.l21, clip.l22];
      levelIds = tutorialIds;
      unlock(tutorialBase);
      start(new Point(Main.WIDTH, Main.HEIGHT));
      scrollMenu.hide();
    }

    public function startMain() : void
    {
      clip = new MainIslandClip();
      levelClips = [clip.bridge, clip.rainbow, clip.crown, clip.czech,
                    clip.littleBigTrouble,
                    clip.widget, clip.lightBulb, clip.musicPlayer,
                    clip.gameSystem, clip.mp3Player, clip.boombox,
                    clip.lime6Pack, clip.dvdPlayer, clip.tank, clip.car];
      levelIds = mainIds;
      unlock(mainBase);
      start(new Point(1600, 1200));
    }

    function start(backgroundSize : Point) : void
    {
      var i = 1;
      for (; i < levelClips.length; ++i)
      {
//        Campaign.levelState[levelIds[i]] = Campaign.ACTIVE;
        updateLevel(i);
      }
      resetWindow(backgroundSize);
      buttons = new ButtonList(levelClips);
      buttons.setActions(click, factoryOver, factoryOut);
      overlay = new IslandOverlayClip();
      parent.addChild(overlay);
      backButtons = new ButtonList([overlay.back]);
      backButtons.setActions(clickBack, backButtons.frameOver,
                             backButtons.frameOut);
      overlay.back.barText.text = "Main Menu";
    }

    function unlock(idList : Array) : void
    {
      for each (var id in idList)
      {
        if (Campaign.levelState[id] == Campaign.INACTIVE)
        {
          Campaign.levelState[id] = Campaign.ACTIVE;
        }
      }
    }

    function factoryOver(index : int) : void
    {
      if (index == 0
          || Campaign.levelState[levelIds[index]] != Campaign.INACTIVE)
      {
        buttons.glowOver(index);
        if (index != 0)
        {
          bubble.visible = true;
          var absolute = new Point(buttons.get(index).x, buttons.get(index).y);
          var relative = window.toRelative(absolute);
          bubble.x = relative.x;
          bubble.y = relative.y;
          var text = "";
          if (index < levelIds.length)
          {
            text = Campaign.levelTitles[levelIds[index]];
          }
          bubble.barText.text = text;
        }
      }
    }

    function factoryOut(index : int) : void
    {
      if (index == 0
          || Campaign.levelState[levelIds[index]] != Campaign.INACTIVE)
      {
        buttons.glowOut(index);
        bubble.visible = false;
      }
    }

    function updateLevel(index : int) : void
    {
      if (index < levelIds.length)
      {
        var state = Campaign.levelState[levelIds[index]];
        if (state == Campaign.ACTIVE
            || state == Campaign.COMPLETE)
        {
          levelClips[index].mouseEnabled = true;
          if (state == Campaign.COMPLETE)
          {
            levelClips[index].gotoAndStop(2);
          }
          else if (state == Campaign.ACTIVE)
          {
            levelClips[index].height = 1;
            newClips.push(levelClips[index]);
          }
        }
        else
        {
          disableLevel(index);
        }
      }
      else
      {
        disableLevel(index);
      }
    }

    function enableLevel(index : int) : void
    {
      levelClips[index].transform.colorTransform = new ColorTransform();
    }

    function disableLevel(index : int) : void
    {
      levelClips[index].transform.colorTransform = ghosted;
    }

    function enterFrame(event : Event) : void
    {
      var maxFrame = 9;
      if (frame < maxFrame)
      {
        for each (var current in newClips)
        {
          if (current.height < 48)
          {
            current.height += maxFrame - (frame/2);
          }
          else
          {
            current.height -= maxFrame - (frame/2);
          }
          if (frame == maxFrame)
          {
            current.height = 48;
          }
        }
        ++frame;
      }
      scrollMenu.enterFrame();
    }

    function click(choice : int) : void
    {
      Sound.play(Sound.SELECT);
      if (choice == 0)
      {
        Campaign.island = 1 - Campaign.island;
        Campaign.islandPos = new Point(0, 0);
        Campaign.save();
        changeIsland();
      }
      else
      {
        if (Campaign.levelState[levelIds[choice]] != Campaign.INACTIVE)
        {
          Campaign.islandPos = window.getOffset().clone();
          Campaign.save();
          Campaign.parse(settings, levelIds[choice]);
          beginGame();
        }
        else
        {
          unlock([levelIds[choice]]);
          enableLevel(choice);
          Campaign.save();
        }
      }
    }

    function clickBack(choice : int) : void
    {
      Campaign.islandPos = window.getOffset().clone();
      Campaign.save();
      Sound.play(Sound.SELECT);
      returnFunction();
    }

    var parent : DisplayObjectContainer;
    var settings : GameSettings;
    var beginGame : Function;
    var returnFunction : Function;
    var changeIsland : Function;
    var keyboard : Keyboard;
    var clip : MovieClip;
    var overlay : IslandOverlayClip;
    var images : lib.ui.ImageList;
    var window : lib.ui.Window;
    var levelClips : Array;
    var levelIds : Array;
    var buttons : ButtonList;
    var backButtons : ButtonList;
    var newClips : Array;
    var frame : int;
    var bubble : FactoryBubbleClip;
    var scrollMenu : ScrollMenu;

    static var ghosted = new ColorTransform(0.3, 0.3, 0.3, 1,
                                            0x70, 0x70, 0x70, 0);

    public static var tutorialBase = ["conveyer-demo"];

    public static var tutorialIds =
      ["", "conveyer-demo", "jam-demo", "sprayer-demo",
       "sensor-demo", "violet", "stencil-demo",
       "imperial", "rotater-demo", "pyramid", "star",
       "mixer-demo", "monaco", "some-demo", "two-triangles",
       "none-demo", "all-demo", "glue-demo", "white-tee",
       "black-box", "mem-demo", "set-clear-demo", "obelisk",
       "sunrise"];

    static var mainBase = ["rainbow", "crown", "czech", "little-big-trouble", "widget"];

    static var mainIds =
      ["", "rainbow", "crown", "czech", "little-big-trouble",
       "widget", "light-bulb", "music-player", "game-system",
       "mp3-player", "boombox", "lime6pack", "dvd-player",
       "tank", "car"];
  }
}

