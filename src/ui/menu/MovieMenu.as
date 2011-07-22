package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import flash.geom.ColorTransform;
  import lib.Point;
  import lib.ui.ButtonList;
  import lib.ui.MenuRoot;
  import lib.ui.Window;
  import logic.Map;
  import ui.Sound;
  import ui.View;

  public class MovieMenu extends MenuRoot
  {
    public function MovieMenu(parent : DisplayObjectContainer,
                              newWindow : Window) : void
    {
      window = newWindow;
      clip = new MovieMenuClip();
      super(parent, clip, false, false);
      buttons = new ButtonList([clip.next, clip.prev]);
      buttons.setActions(click, buttons.glowOver, buttons.glowOut);

      clip.arrow.mouseEnabled = false;
      clip.arrow.mouseChildren = false;
      clip.mouseEnabled = false;

      slide = 0;
      flashFrame = -1;
    }

    public function setModel(newSettings : GameSettings,
                             newEndGame : Function,
                             newSaveMap : Function) : void
    {
      settings = newSettings;
      endGame = newEndGame;
      saveMap = newSaveMap;
      if (settings.shouldSkipToEnd())
      {
        slide = settings.getSlides().length - 1;
      }
      setText();
    }

    override public function cleanup() : void
    {
      buttons.cleanup();
      super.cleanup();
    }

    override public function resize() : void
    {
      Screen.centerX(clip, null);
    }

    static var flashList = [1.0, 1.1, 1.2, 1.3, 1.2, 1.1];

    public function enterFrame() : void
    {
      if (flashFrame >= 0)
      {
        var num = flashList[flashFrame];
        clip.transform.colorTransform = new ColorTransform(num, num, num, 1,
                                                           0, 0, 0, 0);
        --flashFrame;
      }
    }

    function click(choice : int) : void
    {
      if (choice == 0)
      {
        ++slide;
      }
      else
      {
        --slide;
      }
      setText();
      Sound.play(Sound.SELECT);
    }

    function setText() : void
    {
      clip.visible = true;
/*
      window.setScreenOffset(new Point(0, 100));
      if (settings.isMovie())
      {
        window.resizeWindow(new Point(Main.WIDTH, Main.HEIGHT));
      }
      else
      {
        window.resizeWindow(new Point(Main.WIDTH,
                                      Main.HEIGHT - View.MENU_HEIGHT));
      }
*/
      clip.prev.visible = !(slide == 0 && settings.getPrev() == null);
      clip.next.visible = !(slide == settings.getSlides().length - 1
                            && ! settings.isMovie());
      if (slide < 0 && settings.getPrev() != null)
      {
        slide = 0;
        if (settings.getId() != null)
        {
          Campaign.saveLevel(settings.getId(), saveMap());
        }
        endGame(Game.MOVIE_PREV);
      }
      else if (slide >= settings.getSlides().length)
      {
        slide = settings.getSlides().length - 1;
        if (settings.isMovie())
        {
          endGame(Game.MOVIE_NEXT);
        }
        else
        {
          clip.visible = false;
//          window.setScreenOffset(new Point(0, 0));
        }
      }
      else
      {
        var current = settings.getSlides()[slide];
        if (current.align == "middle")
        {
          flashFrame = MAX_FLASH;
        }
        clip.message.text = current.text;
        showArrow(current.pos, current.isPixel);
      }
    }

    function showArrow(mapPos : Point, isPixel : Boolean) : void
    {
      if (mapPos != null)
      {
        var dest = mapPos;
        if (! isPixel)
        {
          var mapPixel = Map.toCenterPixel(mapPos);
          dest = window.toRelative(mapPixel);
          dest.x -= clip.x;
          dest.y -= clip.y;
        }
        var source = new Point(400, 50);
        var diff = new Point(source.x - dest.x, source.y - dest.y);
        var length = Math.sqrt(diff.x*diff.x + diff.y*diff.y);
        var angle = Math.atan2(diff.y, diff.x) * 180 / Math.PI;
        clip.arrow.visible = true;
        clip.arrow.x = dest.x;
        clip.arrow.y = dest.y;
        clip.arrow.rotation = angle;
        clip.arrow.tail.width = length;
      }
      else
      {
        clip.arrow.visible = false;
      }
    }

    var window : lib.ui.Window;
    var clip : MovieMenuClip;
    var buttons : lib.ui.ButtonList;
    var settings : GameSettings;
    var endGame : Function;
    var saveMap : Function;
    var slide : int;
    var flashFrame : int;

    static var MAX_FLASH = flashList.length - 1;
  }
}
