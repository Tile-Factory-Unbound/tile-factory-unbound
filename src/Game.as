// Game.as
//
// The main game object. This handles the main game actions, such as
// winning/losing/etc. as well as containing the two main objects for
// the game, a model for the internal logic and a view for the display
// and UI.

package
{
  import flash.display.DisplayObjectContainer;
  import flash.events.Event;

  import lib.Point;
  import lib.ui.Keyboard;
  import logic.Map;
  import logic.Model;
  import ui.View;

  public class Game implements MainState
  {
    public static var CONTINUE = 0;
    public static var END_GAME = 1;
    public static var RESTART_GAME = 2;
    public static var WIN_GAME = 3;
    public static var MOVIE_NEXT = 4;
    public static var MOVIE_PREV = 5;
    public static var SKIP_GAME = 6;

    public function Game(newParent : DisplayObjectContainer,
                         newKeyboard : lib.ui.Keyboard,
                         newSettings : GameSettings,
                         newEndGameFunction : Function) : void
    {
      parent = newParent;
      keyboard = newKeyboard;
      endGameFunction = newEndGameFunction;
      init(newSettings);
    }

    function init(newSettings : GameSettings) : void
    {
      settings = newSettings;
      nextSettings = null;
      state = CONTINUE;
      view = new ui.View(parent, keyboard, Map.toPixel(settings.getSize()));
      model = new logic.Model(settings, view, endGame);

      parent.addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    public function cleanup() : void
    {
      model.cleanup();
      view.cleanup();
      parent.removeEventListener(Event.ENTER_FRAME, enterFrame);
    }

    public function resize() : void
    {
      view.resize();
    }

    public function endGame(newState : int) : void
    {
      state = newState;
      if (state == WIN_GAME || state == SKIP_GAME)
      {
        for each (var unlock in settings.getUnlocks())
        {
          if (Campaign.levelState[unlock] == Campaign.INACTIVE)
          {
            Campaign.levelState[unlock] = Campaign.ACTIVE;
          }
        }
      }
      if (state == SKIP_GAME)
      {
        if (settings.isMovie())
        {
          state = MOVIE_NEXT;
        }
        else
        {
          state = END_GAME;
        }
      }
      if (state == WIN_GAME)
      {
        state = END_GAME;
        Campaign.levelState[settings.getWinId()] = Campaign.COMPLETE;
        Campaign.save();
        if (Main.kongregate != null)
        {
          if (Campaign.winFirst())
          {
            Main.kongregate.stats.submit("Tile Player", 1);
            if (Campaign.winTutorial())
            {
              Main.kongregate.stats.submit("Tile Winner", 1);
              if (Campaign.winMain())
              {
                Main.kongregate.stats.submit("Tile Master", 1);
              }
            }
          }
        }
      }
      else if (state == MOVIE_NEXT || state == MOVIE_PREV)
      {
        var isPrev = (state == MOVIE_PREV);
        state = END_GAME;
        var nextId = settings.getNext();
        if (isPrev)
        {
          nextId = settings.getPrev();
        }
        if (nextId != null)
        {
          setNextSettings(nextId, isPrev);
        }
      }
    }

    function enterFrame(event : Event) : void
    {
      if (state == END_GAME)
      {
        var shouldSelectLevel = true;
        if (settings.getId() == null || settings.getId() == "sandbox")
        {
          shouldSelectLevel = false;
        }
        endGameFunction(shouldSelectLevel);
      }
      else if (state == RESTART_GAME)
      {
        if (nextSettings == null)
        {
          if (settings.getId() != null)
          {
            setNextSettings(settings.getId(), false);
          }
          else
          {
            nextSettings = settings;
          }
        }
        cleanup();
        init(nextSettings);
        resize();
      }
      else
      {
        model.enterFrame();
        view.enterFrame();
      }
    }

    // isPrev is true if the game is ending because the previous
    // button was clicked at the beginning of a slide show.
    function setNextSettings(nextId : String, isPrev : Boolean) : void
    {
      var next = new GameSettings(new Point(25, 25));
      if (Campaign.parse(next, nextId))
      {
        nextSettings = next;
        nextSettings.setWinId(settings.getWinId());
        if (isPrev)
        {
          nextSettings.setSkipToEnd();
        }
        state = RESTART_GAME;
      }
    }

    var parent : DisplayObjectContainer;
    var keyboard : lib.ui.Keyboard;
    var endGameFunction : Function;
    var settings : GameSettings;
    var nextSettings : GameSettings;
    var state : int;
    var view : ui.View;
    var model : logic.Model;
  }
}
