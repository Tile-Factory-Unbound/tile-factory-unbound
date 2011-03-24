package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import lib.Point;
  import lib.ui.ButtonList;
  import lib.ui.MenuRoot;
  import lib.ui.Window;
  import logic.ButtonStatus;
  import logic.Item;
  import logic.Map;
  import logic.Part;
  import ui.GoalPlace;
  import ui.PartPlace;
  import ui.RegionList;
  import ui.Sound;
  import ui.TabList;
  import ui.View;

  public class TileMenu extends TabMenu
  {
    public static var TILE_EDIT = 0;
    public static var TILE_LAB = 1;
    public static var COLOR_LAB = 2;

    public function TileMenu(parent : DisplayObjectContainer,
                             newWindow : Window,
                             newGoalPlace : GoalPlace,
                             setMenu : Function,
                             newType : int) : void
    {
      testColor = -1;
      testLeft = -1;
      testRight = -1;
      testTile = null;

      type = newType;
      goalPlace = newGoalPlace;
      window = newWindow;
      clip = new TileMenuClip();
      side = new TileMenuSide();
      parent.addChild(side);
      parent.setChildIndex(side, 0);
      side.visible = false;
      var index = TabList.TILE_MENU;
      if (type == TILE_LAB)
      {
        index = TabList.TILE_LAB_MENU;
      }
      else if (type == COLOR_LAB)
      {
        index = TabList.COLOR_LAB_MENU;
      }

      super(parent, clip, setMenu, index);

      buttons = new ButtonList([clip.p.deleteButton]);
      buttons.setActions(click, buttons.frameOver, buttons.frameOut);

      clip.p.deleteButton.barText.text = "Clear";

      if (type == TILE_EDIT)
      {
        side.test.visible = false;
        side.testLabel.visible = false;
        side.paint.visible = false;
      }
      else if (type == TILE_LAB)
      {
        side.paint.visible = false;
      }
      else if (type == COLOR_LAB)
      {
        side.test.visible = false;
      }

      var tileButtonList = [clip.p.b0, clip.p.b1, clip.p.b2,
                            clip.p.b3, clip.p.b4, clip.p.b5,
                            clip.p.b6, clip.p.b7, clip.p.b8,
                            clip.p.b9, clip.p.b10, clip.p.b11,
                            clip.p.b12, clip.p.b13, clip.p.b14,
                            clip.p.b15,
                            clip.p.s0, clip.p.s1, clip.p.s2,
                            clip.p.s3, clip.p.s4, clip.p.s5,
                            clip.p.clockwise, clip.p.counter];
      tileButtons = new ButtonList(tileButtonList);
      tileButtons.setActions(tileClick, tileButtons.glowOver,
                             tileButtons.glowOut);
      var i = 0;
      for (i = BEGIN_PAINT; i < END_PAINT; ++i)
      {
        tileButtonList[i].gotoAndStop(i + 9 - BEGIN_PAINT);
      }
      for (i = BEGIN_STENCIL; i < END_STENCIL; ++i)
      {
        tileButtonList[i].gotoAndStop(i + 4 - BEGIN_STENCIL);
      }
      tileButtonList[SOLVENT].gotoAndStop(2);
      stencilDir = Dir.east;
    }

    override public function cleanup() : void
    {
      side.parent.removeChild(side);
      buttons.cleanup();
      tileButtons.cleanup();
      super.cleanup();
    }

    public function setModel(newPartPlace : PartPlace,
                             buttonStatus : ButtonStatus) : void
    {
      partPlace = newPartPlace;
      if (type == COLOR_LAB)
      {
        if (! buttonStatus.getStatus(Part.MIXER))
        {
          clip.visible = false;
        }
      }
    }

    override public function show() : void
    {
      super.show();
      goalPlace.selectTiles();
      if (goalPlace.hasTile())
      {
        updateTile();
        updateTest();
        window.resizeWindow(new Point(Main.WIDTH - 200,
                                      Main.HEIGHT - View.MENU_HEIGHT));
        side.visible = true;
        var goal = goalPlace.getGoalOffset();
        window.setOffset(Map.toPixel(new Point(goal.x - 1, goal.y - 1)));
        clip.p.visible = true;
        clip.message.visible = false;
        var showStencils = (type == TILE_EDIT || type == TILE_LAB);
        for each (var stencil in [clip.p.s0, clip.p.s1, clip.p.s2, clip.p.s3,
                                  clip.p.s4, clip.p.s5, clip.p.clockwise,
                                  clip.p.counter])
        {
          stencil.visible = showStencils;
        }
      }
      else
      {
        side.visible = false;
        clip.p.visible = false;
        clip.message.visible = true;
      }
      partPlace.hide();
      goalPlace.toggleGoalHeight();
    }

    override public function hide() : void
    {
      super.hide();
      window.resizeWindow(new Point(Main.WIDTH,
                                    Main.HEIGHT - View.MENU_HEIGHT));
      side.visible = false;
      if (partPlace != null)
      {
        partPlace.show();
      }
      goalPlace.toggleGoalHeight();
    }

    function click(choice : int) : void
    {
      if (type == TILE_EDIT)
      {
        goalPlace.deleteTile();
      }
      else if (type == TILE_LAB)
      {
        testTile = null;
      }
      else if (type == COLOR_LAB)
      {
        testColor = -1;
      }
      updateTile();
      updateTest();
      Sound.play(Sound.SELECT);
    }

    static var BEGIN_PAINT = 0;
    static var END_PAINT = 16;
    static var BEGIN_STENCIL = 16;
    static var END_STENCIL = 21;
    static var SOLVENT = 21;
    static var CLOCKWISE = 22;
    static var COUNTER = 23;

    function tileClick(choice : int) : void
    {
      if (type == COLOR_LAB)
      {
        colorTypeClick(choice);
      }
      else
      {
        tileTypeClick(choice);
      }
      Sound.play(Sound.SELECT);
    }

    function colorTypeClick(choice : int) : void
    {
      if (testColor >= 0)
      {
        testLeft = testColor;
        testRight = choice - BEGIN_PAINT;
        testColor = RegionList.mix(testLeft, testRight);
      }
      else
      {
        testColor = choice - BEGIN_PAINT;
        testLeft = testColor;
        testRight = testColor;
      }
      updateTest();
    }

    function tileTypeClick(choice : int) : void
    {
      var color = testTile;
      if (type == TILE_EDIT)
      {
        color = goalPlace.getTileColor();
      }
      if (color == null)
      {
        color = new RegionList();
        if (type == TILE_EDIT)
        {
          goalPlace.setTileColor(color);
        }
      }
      if (choice >= BEGIN_PAINT && choice < END_PAINT)
      {
        color.paint(choice - BEGIN_PAINT);
      }
      else if (choice >= BEGIN_STENCIL && choice < END_STENCIL)
      {
        applyStencil(color, RegionList.stencils[choice - BEGIN_STENCIL]);
      }
      else if (choice == SOLVENT)
      {
        color.solvent();
      }
      else if (choice == CLOCKWISE)
      {
        stencilDir = stencilDir.clockwise();
        updateStencils();
      }
      else if (choice == COUNTER)
      {
        stencilDir = stencilDir.counter();
        updateStencils();
      }
      if (type == TILE_EDIT)
      {
        goalPlace.setTileColor(color);
      }
      else if (type == TILE_LAB)
      {
        testTile = color;
      }
      updateTile();
      updateTest();
    }

    function updateTile() : void
    {
      var color = goalPlace.getTileColor();
      updateTileView(color, side.tile);
    }

    function updateTileView(color : RegionList, canvas : TileZoomClip) : void
    {
      if (color != null)
      {
        canvas.stencil.visible = true;
        color.drawRegions(canvas.draw.graphics, 0, 300);
      }
      else
      {
        canvas.stencil.visible = false;
        canvas.draw.graphics.clear();
      }
    }

    function updateTest() : void
    {
      if (type == TILE_LAB)
      {
        updateTileView(testTile, side.test);
      }
      else if (type == COLOR_LAB)
      {
        if (testColor >= 0)
        {
          side.paint.visible = true;
          side.paint.result.gotoAndStop(testColor + Item.PAINT_BEGIN);
          side.paint.left.gotoAndStop(testLeft + Item.PAINT_BEGIN);
          side.paint.right.gotoAndStop(testRight + Item.PAINT_BEGIN);
        }
        else
        {
          side.paint.visible = false;
        }
      }
    }

    function updateStencils() : void
    {
      for each (var stencil in [clip.p.s0, clip.p.s1, clip.p.s2, clip.p.s3,
                                clip.p.s4])
      {
        stencil.rotation = stencilDir.toAngle();
      }
    }

    function applyStencil(color : RegionList, stencilMask : int) : void
    {
      var stencil = new RegionList();
      stencil.addStencil(stencilMask);
      var dir = Dir.east;
      while (dir != stencilDir)
      {
        dir = dir.clockwise();
        stencil.clockwise();
      }
      color.addStencil(stencil.getStencil());
    }

    var goalPlace : ui.GoalPlace;
    var window : lib.ui.Window;
    var clip : TileMenuClip;
    var side : TileMenuSide;
    var buttons : lib.ui.ButtonList;
    var tileButtons : lib.ui.ButtonList;
    var stencilDir : Dir;
    var partPlace : ui.PartPlace;
    var type : int;
    var testColor : int;
    var testLeft : int;
    var testRight : int;
    var testTile : RegionList;
  }
}
