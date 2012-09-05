package lib.ui
{
  public class MenuList
  {
    public static var HIDE_MENU = -2;
    public static var CURRENT_MENU = -1;

    public function MenuList(newMenus : Array) : void
    {
      current = 0;
      menus = newMenus;
      isHidden = true;
/*
      if (current >= 0 && current < menus.length)
      {
        menus[current].show();
      }
*/
    }

    public function cleanup() : void
    {
      for each(var menu in menus)
      {
        menu.cleanup();
      }
    }

    public function update() : void
    {
      if (current >= 0 && current < menus.length)
      {
        var next = menus[current].getNextMenu();
        if (next == HIDE_MENU)
        {
          hide();
        }
        else
        {
          changeState(next);
        }
      }
    }

    public function hide() : void
    {
      if (current >= 0 && current < menus.length)
      {
        menus[current].hide();
      }
      isHidden = true;
    }

    public function show() : void
    {
      if (current >= 0 && current < menus.length)
      {
        menus[current].show();
        isHidden = false;
      }
    }

    public function changeState(next : int) : void
    {
      if (next != CURRENT_MENU
          && next >= 0 && next < menus.length)
      {
        if (! isHidden)
        {
          if (current >= 0 && current < menus.length)
          {
            menus[current].hide();
          }
        }
        current = next;
        menus[current].show();
        isHidden = false;
      }
    }

    var current : int;
    var menus : Array;
    var isHidden : Boolean;
  }
}
