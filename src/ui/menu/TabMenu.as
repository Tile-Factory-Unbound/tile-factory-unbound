package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import flash.display.MovieClip;
  import lib.ui.ButtonList;
  import lib.ui.MenuRoot;
  import ui.Sound;
  import ui.TabList;

  public class TabMenu extends MenuRoot
  {
    public function TabMenu(parent : DisplayObjectContainer,
                            clip : MovieClip,
                            newSetMenu : Function,
                            newMenuIndex : int) : void
    {
      super(parent, clip, false, false);
      tabButtons = new ButtonList([rootClip.tabButton]);
      tabButtons.setActions(clickTab, tabButtons.glowOver,
                            tabButtons.glowOut);
      setMenu = newSetMenu;
      menuIndex = newMenuIndex;
      rootClip.tabButton.barText.text = TabList.tabText[menuIndex];
      hide();
    }

    override public function cleanup() : void
    {
      tabButtons.cleanup();
      super.cleanup();
    }

    override public function show() : void
    {
      rootClip.parent.setChildIndex(rootClip, rootClip.parent.numChildren - 1);
      rootClip.tabButton.gotoAndStop(1);
    }

    override public function hide() : void
    {
      rootClip.tabButton.gotoAndStop(2);
    }

    public function disable() : void
    {
      rootClip.visible = false;
    }

    public function setTabPos(newX : int) : void
    {
      rootClip.tabButton.x = newX;
    }

    function clickTab(choice : int) : void
    {
      setMenu(menuIndex);
      Sound.play(Sound.SELECT);
    }

    protected var tabButtons : lib.ui.ButtonList;
    protected var setMenu : Function;
    var menuIndex : int;
  }
}
