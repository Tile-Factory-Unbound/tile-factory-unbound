package ui.menu
{
  import flash.display.DisplayObjectContainer;
  import lib.Point;
  import lib.ui.ButtonList;
  import ui.PartPlace;
  import ui.Sound;
  import ui.StampButtons;
  import ui.StencilButtons;
  import ui.TabList;
  import ui.TileDisplay;
  import ui.TilePixel;

  public class StencilMenu extends TabMenu
  {
    public function StencilMenu(parent : DisplayObjectContainer,
                                setMenu : Function) : void
    {
      clip = new StencilMenuClip();

      grid = new StencilMenuGrid();
      parent.addChild(grid);

      super(parent, clip, setMenu, TabList.STENCIL_MENU);

      buttons = new ButtonList([clip.applyButton, clip.cancelButton]);
      buttons.setActions(click, buttons.frameOver, buttons.frameOut);
      clip.applyButton.barText.text = "Apply";
      clip.cancelButton.barText.text = "Cancel";

      stencilButtons = new ButtonList([clip.s1, clip.s2, clip.s3,
                                       clip.s4, clip.s5]);
      stencilButtons.setActions(clickStencil, stencilButtons.glowOver,
                                stencilButtons.glowOut);
      editChoice = -1;
      tile = new TileDisplay(grid.grid, null, false, true);
      grid.visible = false;
      stampManager = new StampButtons(clip.stamps, clickStamp);
    }

    override public function cleanup() : void
    {
      stampManager.cleanup();
      if (stencilManager != null)
      {
        stencilManager.cleanup();
      }
      tile.cleanup();
      buttons.cleanup();
      stencilButtons.cleanup();
      super.cleanup();
      grid.parent.removeChild(grid);
    }

    override public function resize() : void
    {
      super.resize();
      Screen.centerX(grid, new Point(0, 0));
      grid.y = 30 + 210;
    }

    public function setModel(newPartPlace : PartPlace,
                             newStencils : Array) : void
    {
      partPlace = newPartPlace;
      stencils = newStencils;
      stencilManager = new StencilButtons([clip.s1, clip.s2, clip.s3, clip.s4,
                                           clip.s5], stencils);
    }

    override public function show() : void
    {
      super.show();
      if (editChoice == -1)
      {
        for each (var shown in [clip.s1, clip.s2, clip.s3, clip.s4, clip.s5])
        {
          shown.visible = true;
        }
        clip.message.visible = true;
        clip.applyButton.visible = false;
        clip.cancelButton.visible = false;
        grid.visible = false;
        stampManager.hide();
      }
      else
      {
        for each (var hidden in [clip.s1, clip.s2, clip.s3, clip.s4, clip.s5])
        {
          hidden.visible = false;
        }
        clip.message.visible = false;
        clip.applyButton.visible = true;
        clip.cancelButton.visible = true;
        grid.visible = true;
        tile.reset(stencils[editChoice]);
        stampManager.show();
      }
      partPlace.hide();
      stencilManager.reset();
    }

    override public function hide() : void
    {
      super.hide();
      grid.visible = false;
      if (partPlace != null)
      {
        partPlace.show();
      }
      editChoice = -1;
      if (stampManager != null)
      {
        stampManager.hide();
      }
    }

    static var APPLY = 0;
    static var CANCEL = 1;

    function click(choice : int) : void
    {
      if (choice == APPLY)
      {
        stencils[editChoice] = tile.get();
      }
      editChoice = -1;
      show();
      Sound.play(Sound.SELECT);
    }

    function clickStencil(choice : int) : void
    {
      editChoice = choice;
      show();
      Sound.play(Sound.SELECT);
    }

    function clickStamp(choice : TilePixel) : void
    {
      tile.reset(choice);
    }

    var clip : StencilMenuClip;
    var grid : StencilMenuGrid;
    var buttons : ButtonList;
    var stencilButtons : ButtonList;
    var editChoice : int;
    var tile : TileDisplay;
    var partPlace : ui.PartPlace;
    var stencils : Array;
    var stencilManager : StencilButtons;
    var stampManager : StampButtons;
  }
}
