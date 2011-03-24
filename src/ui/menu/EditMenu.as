package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import lib.ui.ButtonList;
  import lib.ui.Window;
  import logic.Map;
  import logic.Part;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.Sound;
  import ui.TabList;

  public class EditMenu extends TabMenu
  {
    public function EditMenu(parent : DisplayObjectContainer,
                             newWindow : Window,
                             newGoalPlace : GoalPlace,
                             newSetMenu : Function) : void
    {
      window = newWindow;
      goalPlace = newGoalPlace;
      setMenu = newSetMenu;
      clip = new EditMenuClip();
      super(parent, clip, setMenu, TabList.EDIT_MENU);
      buttons = new ButtonList([clip.widthSub1,
                                clip.widthSub5,
                                clip.widthAdd1,
                                clip.widthAdd5,
                                clip.heightSub1,
                                clip.heightSub5,
                                clip.heightAdd1,
                                clip.heightAdd5]);
      buttons.setActions(click, buttons.glowOver, buttons.glowOut);
    }

    public function setModel(newMap : Map,
                             newPartPlace : PartPlace,
                             newSettings : GameSettings,
                             newForEachPart : Function) : void
    {
      map = newMap;
      partPlace = newPartPlace;
      settings = newSettings;
      clip.nameField.text = settings.getName();
      forEachPart = newForEachPart;
    }

    override public function cleanup() : void
    {
      buttons.cleanup();
      super.cleanup();
    }

    static var WIDTH_SUB_1 = 0;
    static var WIDTH_SUB_5 = 1;
    static var WIDTH_ADD_1 = 2;
    static var WIDTH_ADD_5 = 3;
    static var HEIGHT_SUB_1 = 4;
    static var HEIGHT_SUB_5 = 5;
    static var HEIGHT_ADD_1 = 6;
    static var HEIGHT_ADD_5 = 7;

    function click(choice : int) : void
    {
      if (choice == WIDTH_SUB_1)
      {
        changeSize(Dir.east, -1);
      }
      else if (choice == WIDTH_SUB_5)
      {
        changeSize(Dir.east, -5);
      }
      else if (choice == WIDTH_ADD_1)
      {
        changeSize(Dir.east, 1);
      }
      else if (choice == WIDTH_ADD_5)
      {
        changeSize(Dir.east, 5);
      }
      else if (choice == HEIGHT_SUB_1)
      {
        changeSize(Dir.south, -1);
      }
      else if (choice == HEIGHT_SUB_5)
      {
        changeSize(Dir.south, -5);
      }
      else if (choice == HEIGHT_ADD_1)
      {
        changeSize(Dir.south, 1);
      }
      else if (choice == HEIGHT_ADD_5)
      {
        changeSize(Dir.south, 5);
      }
      Sound.play(Sound.SELECT);
    }

    override public function show() : void
    {
      super.show();
      partPlace.hide();
      goalPlace.hide();
    }

    override public function hide() : void
    {
      if (settings != null)
      {
        settings.setName(clip.nameField.text);
      }
      if (partPlace != null)
      {
        partPlace.show();
      }
      goalPlace.show();
      super.hide();
    }

    function changeSize(dir : Dir, delta : int) : void
    {
      if (goalPlace.canChangeSize(Dir.walk(map.getSize(), dir, delta)))
      {
        forEachPart(removeTrack);
        if (map.changeSize(dir, delta))
        {
          window.resizeBackground(Map.toPixel(map.getSize()));
        }
        forEachPart(addTrack);
      }
    }

    function removeTrack(part : Part) : void
    {
      part.removeAllTracks();
    }

    function addTrack(part : Part) : void
    {
      part.addAllTracks();
    }

    var clip : EditMenuClip;
    var buttons : lib.ui.ButtonList;
    var map : logic.Map;
    var window : lib.ui.Window;
    var goalPlace : ui.GoalPlace;
    var partPlace : ui.PartPlace;
    var settings : GameSettings;
    var forEachPart : Function;
  }
}
