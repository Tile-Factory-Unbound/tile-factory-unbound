package ui
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.text.TextField;
  import lib.ChangeList;
  import lib.ui.MenuList;
  import lib.ui.Window;
  import logic.Map;
  import ui.menu.ButtonMenu;
  import ui.menu.EditMenu;
  import ui.menu.GoalMenu;
  import ui.menu.ItemMenu;
  import ui.menu.PartMenu;
  import ui.menu.PlaceMenu;
  import ui.menu.StencilMenu;
  import ui.menu.TileMenu;
  import ui.menu.VictoryMenu;
  import ui.menu.WireMenu;

  public class TabList
  {
    public function TabList(parent : DisplayObjectContainer,
                            window : Window, goalPlace : GoalPlace,
                            wirePlace : WirePlace,
                            wireParent : WireParent) : void
    {
      clip = new Sprite();
      parent.addChild(clip);

      buttonMenu = new ButtonMenu(clip, setMenu, goalPlace);
      editMenu = new EditMenu(clip, window, goalPlace, setMenu);
      placeMenu = new PlaceMenu(clip, goalPlace);
      goalMenu = new GoalMenu(clip, goalPlace, setMenu);
      tileMenu = new TileMenu(clip, window, goalPlace, setMenu,
                              TileMenu.TILE_EDIT);
      victoryMenu = new VictoryMenu(clip, setMenu, goalPlace);
      partMenu = new PartMenu(clip, setMenu, goalPlace);
      itemMenu = new ItemMenu(clip, setMenu, goalPlace);
      wireMenu = new WireMenu(clip, setMenu, wirePlace, wireParent, goalPlace);
      colorLabMenu = new TileMenu(clip, window, goalPlace, setMenu,
                                  TileMenu.COLOR_LAB);
      tileLabMenu = new TileMenu(clip, window, goalPlace, setMenu,
                                 TileMenu.TILE_LAB);
      stencilMenu = new StencilMenu(clip, setMenu);
      menuList = new MenuList([buttonMenu, editMenu, placeMenu, goalMenu,
                               tileMenu, victoryMenu, partMenu, itemMenu,
                               wireMenu, colorLabMenu, tileLabMenu,
                               stencilMenu]);
    }

    public function cleanup() : void
    {
      clip.parent.removeChild(clip);
      menuList.cleanup();
    }

    public function resize() : void
    {
      for each (var current in [buttonMenu, editMenu, placeMenu, goalMenu,
                                tileMenu, victoryMenu, partMenu, itemMenu,
                                wireMenu, colorLabMenu, tileLabMenu,
                                stencilMenu])
      {
        current.resize();
      }
    }

    public function setModel(settings : GameSettings,
                             changes : lib.ChangeList,
                             map : logic.Map,
                             forEachPart : Function,
                             endGame : Function,
                             saveMap : Function,
                             partPlace : PartPlace,
                             countParts : Function,
                             countSteps : Function,
                             countCreated : Function,
                             countBroken : Function,
                             tip : ToolTipClip,
                             stencils : Array)
    {
      partMenu.setModel(partPlace, settings.isEditor(),
                        settings.getButtonStatus(), tip);
      itemMenu.setModel(partPlace, settings.isEditor(),
                        settings.getButtonStatus(), stencils)
      buttonMenu.setModel(settings.getButtonStatus(), partPlace, stencils);
      editMenu.setModel(map, partPlace, settings, forEachPart);
      placeMenu.setModel(partPlace);
      victoryMenu.setModel(settings, endGame, partPlace,
                           countParts, countSteps, countCreated, countBroken);
      wireMenu.setModel(partPlace, settings.getButtonStatus(),
                        settings.isEditor());
      goalMenu.setModel(partPlace);
      tileMenu.setModel(partPlace, settings.getButtonStatus(), stencils);
      colorLabMenu.setModel(partPlace, settings.getButtonStatus(), stencils);
      tileLabMenu.setModel(partPlace, settings.getButtonStatus(), stencils);
      stencilMenu.setModel(partPlace, stencils);
      setMenu(PART_MENU);
      if (settings.isMovie())
      {
        clip.visible = false;
      }
      if (settings.isEditor())
      {
        setupTabs([partMenu, itemMenu, wireMenu,
                   editMenu, buttonMenu, goalMenu, tileMenu, stencilMenu]);
        for each (var player in [colorLabMenu, tileLabMenu, victoryMenu])
        {
          player.disable();
        }
      }
      else
      {
        setupTabs([partMenu, itemMenu, wireMenu,
                   colorLabMenu, tileLabMenu, victoryMenu]);
        for each (var editor in [editMenu, buttonMenu, goalMenu, tileMenu])
        {
          editor.disable();
        }
      }
      if (settings.getId() == "sandbox")
      {
        colorLabMenu.disable();
        tileLabMenu.disable();
      }
    }

    function setupTabs(tabs : Array) : void
    {
      var x = 12;
      for each (var current in tabs)
      {
        current.setTabPos(x);
        x += 97;
      }
    }

    public function enterFrame() : void
    {
      menuList.update();
    }

    public function setMenu(newState : int) : void
    {
      menuList.changeState(newState);
    }

    public function refreshMenu() : void
    {
      menuList.hide();
      menuList.show();
    }

    public function getWireText() : TextField
    {
      return wireMenu.getWireText();
    }

    public function hide() : void
    {
      clip.visible = false;
    }

    public function show() : void
    {
      clip.visible = true;
    }

    var clip : flash.display.Sprite;

    var menuList : lib.ui.MenuList;
    var buttonMenu : ui.menu.ButtonMenu;
    var editMenu : ui.menu.EditMenu;
    var placeMenu : ui.menu.PlaceMenu;
    var goalMenu : ui.menu.GoalMenu;
    var tileMenu : ui.menu.TileMenu;
    var victoryMenu : ui.menu.VictoryMenu;
    var partMenu : ui.menu.PartMenu;
    var itemMenu : ui.menu.ItemMenu;
    var wireMenu : ui.menu.WireMenu;
    var colorLabMenu : ui.menu.TileMenu;
    var tileLabMenu : ui.menu.TileMenu;
    var stencilMenu : ui.menu.StencilMenu;

    public static var BUTTON_MENU = 0;
    public static var EDIT_MENU = 1;
    public static var PLACE_MENU = 2;
    public static var GOAL_MENU = 3;
    public static var TILE_MENU = 4;
    public static var VICTORY_MENU = 5;
    public static var PART_MENU = 6;
    public static var ITEM_MENU = 7;
    public static var WIRE_MENU = 8;
    public static var COLOR_LAB_MENU = 9;
    public static var TILE_LAB_MENU = 10;
    public static var STENCIL_MENU = 11;

    public static var tabText = ["Buttons", "Map", "Place", "Goal", "Tile",
                                 "Victory", "Parts", "Items", "Wires",
                                 "Dye Lab", "Tile Lab", "Stencils"];
  }
}
