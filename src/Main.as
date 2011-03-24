package
{
  import flash.display.DisplayObjectContainer;
  import lib.Point;
  import lib.ui.Keyboard;
  import ui.RegionList;
  import ui.Sound;

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
        Campaign.init();
        Sound.playMusic();
        root = parent;
        keyboard = new lib.ui.Keyboard(root.stage);
        ui.RegionList.setupRegions();
        settings = new GameSettings(new lib.Point(25, 25));
        state = new MainMenu(root, settings, beginGame, keyboard);
      }
    }

    static function beginGame() : void
    {
      state.cleanup();
      state = new Game(root, keyboard, settings, endGame);
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
    }

    static var root : DisplayObjectContainer;
    static var state : MainState;
    static var keyboard : lib.ui.Keyboard;
    static var settings : GameSettings;

    public static var kongregate : * = null;
  }
}
