package ui
{
  import lib.ui.ButtonList;

  public class StampButtons
  {
    public function StampButtons(newParent : StampClip,
                                 newOnClick : Function) : void
    {
      parent = newParent;
      onClick = newOnClick;
      offset = 0;
      stencilColors = null;
      stencilClips = null;
      stencilTiles = null;
      stencilButtons = null;
      navButtons = new ButtonList([parent.left, parent.right]);
      navButtons.setActions(navClick, navButtons.glowOver,
                            navButtons.glowOut);
    }

    public function cleanup() : void
    {
      navButtons.cleanup();
      if (stencilClips != null)
      {
        stencilButtons.cleanup();
        for each (var tile in stencilTiles)
        {
          tile.cleanup();
        }
        for each (var clip in stencilClips)
        {
          clip.parent.removeChild(clip);
        }
      }
    }

    public function show() : void
    {
      parent.visible = true;
      offset = 0;
      update();
    }

    public function hide() : void
    {
      parent.visible = false;
    }

    private function initClips() : void
    {
      stencilColors = [];
      for each (var stamp in Stamps.stamps)
      {
        var color = new TilePixel();
        color.fromStamp(stamp);
        stencilColors.push(color);
      }
      stencilClips = [];
      stencilTiles = [];
      var row = 0;
      for (; row < ROW_COUNT; ++row)
      {
        var col = 0;
        for (; col < COL_COUNT; ++col)
        {
          var clip = new StencilBackground();
          parent.addChild(clip);
          clip.x = 39 + (78-39)*col;
          clip.y = 45 + (80-45)*row;
          stencilClips.push(clip);
          var tile = new TileDisplay(clip, stencilColors[0], false, false);
          stencilTiles.push(tile);
        }
      }
      stencilButtons = new ButtonList(stencilClips);
      stencilButtons.setActions(stencilClick, stencilButtons.glowOver,
                                stencilButtons.glowOut);
    }

    private function update() : void
    {
      if (stencilClips == null)
      {
        initClips();
      }
      var i = 0;
      for (; i < stencilClips.length; ++i)
      {
        if (offset + i >= stencilColors.length)
        {
          stencilClips[i].visible = false;
        }
        else
        {
          stencilClips[i].visible = true;
          stencilTiles[i].reset(stencilColors[offset + i]);
        }
      }
      parent.left.visible = (offset > 0);
      parent.right.visible = (offset + (ROW_COUNT*COL_COUNT)
                                                < stencilColors.length);
    }

    private function navClick(choice : int) : void
    {
      if (choice == 0)
      {
        offset -= ROW_COUNT * COL_COUNT;
      }
      else
      {
        offset += ROW_COUNT * COL_COUNT;
      }
      update();
    }

    private function stencilClick(choice : int) : void
    {
      onClick(stencilColors[offset + choice]);
    }

    private var parent : StampClip;
    private var onClick : Function;
    private var offset : int;
    private var stencilColors : Array;
    private var stencilClips : Array;
    private var stencilTiles : Array;
    private var navButtons : ButtonList;
    private var stencilButtons : ButtonList;

    private static var ROW_COUNT = 2;
    private static var COL_COUNT = 16;
  }
}
