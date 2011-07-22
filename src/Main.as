package
{
  import flash.display.DisplayObjectContainer;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.FullScreenEvent;
  import lib.Point;
  import lib.ui.Keyboard;
  import ui.RegionList;
  import ui.Sound;
  import ui.TilePixel;

  public class Main
  {
    public static var WIDTH = 800;
    public static var HEIGHT = 600;

    public static function init(parent : DisplayObjectContainer) : void
    {
      var url = parent.stage.loaderInfo.url.split("/")[2];
//      if (url == "jayisgames.com" || url == "casualgameplay.com"
//          || url == "cgdc8.fizzlebot.com")
//      if (url.indexOf("armorgames.com") != -1)
//      if (url.indexOf("kongregate.com") != -1)
      {
        var stage = parent.stage;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        stage.addEventListener(FullScreenEvent.FULL_SCREEN,
                               fullScreenHandler);
        stage.addEventListener(Event.RESIZE,
                               resizeHandler);
        Campaign.init();
        Sound.playMusic();
        root = parent;
        keyboard = new lib.ui.Keyboard(root.stage);
        ui.TilePixel.setupRegions();
        ui.RegionList.setupRegions();
        settings = new GameSettings(new lib.Point(25, 25));
        state = new MainMenu(root, settings, beginGame, keyboard);
        resize();
      }
    }

    static function beginGame() : void
    {
      state.cleanup();
      state = new Game(root, keyboard, settings, endGame);
      resize();
    }

    static function endGame(shouldSelectLevel : Boolean) : void
    {
      state.cleanup();
      settings = new GameSettings(new lib.Point(25, 25));
      var menu = new MainMenu(root, settings, beginGame, keyboard);
      state = menu;
      if (shouldSelectLevel)
      {
        menu.selectLevel();
      }
      resize();
    }

    static function fullScreenHandler(event : FullScreenEvent) : void
    {
      resize();
    }

    static function resizeHandler(event : Event) : void
    {
      resize();
    }

    static function resize() : void
    {
      state.resize();
    }

    static var root : DisplayObjectContainer;
    static var state : MainState;
    static var keyboard : lib.ui.Keyboard;
    static var settings : GameSettings;

    public static var kongregate : * = null;
  }
}
