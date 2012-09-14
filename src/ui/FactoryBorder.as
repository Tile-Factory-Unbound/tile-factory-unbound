package ui
{
  import flash.display.DisplayObjectContainer;
  import flash.display.MovieClip;
  import flash.events.MouseEvent;
  import flash.geom.Rectangle;
  import lib.Point;
  import lib.ui.WindowBorder;
  import logic.Map;

  public class FactoryBorder extends WindowBorder
  {
    public function FactoryBorder(newType : int) : void
    {
      type = newType;
      super();
    }

    override public function init(parent : DisplayObjectContainer) : void
    {
      children = [];
      east = [];
      south = [];
      super.init(parent);
      createClip(new GrassEdgeClip(), 1024, Map.tileSize, 0, false, false);
      createClip(new GrassEdgeClip(), 1024, 0, 180, true, false);
      createClip(new GrassEdgeClip(), 0, 1024, 90, false, true);
      createClip(new GrassEdgeClip(), Map.tileSize, 1024, -90, false, false);
      createClip(new GrassCornerClip(), Map.tileSize, Map.tileSize,
                 0, false, false);
      createClip(new GrassCornerClip(), 0, Map.tileSize, 90, false, true);
      createClip(new GrassCornerClip(), 0, 0, 180, true, true);
      createClip(new GrassCornerClip(), Map.tileSize, 0, -90, true, false);
      border = new GrassOutsideClip();
      clip.addChild(border);
      clip.graphics.drawRect(-5*32, -5*32, 11*32, 11*32);
      clip.scale9Grid = new Rectangle(0, 0, 32, 32);
      clip.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
      clip.x = - Map.tileSize;
      clip.y = - Map.tileSize;
    }

    public function setModel(newPartPlace : PartPlace)
    {
      partPlace = newPartPlace;
    }

    override public function cleanup() : void
    {
      clip.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
      cleanupChildren();
      border.parent.removeChild(border);
      super.cleanup();
    }

    function cleanupChildren() : void
    {
      for each (var child in children)
      {
        child.parent.removeChild(child);
      }
      children = [];
      south = [];
      east = [];
    }

    override public function update(offset : Point, screen : Point,
                                    size : Point, windowSize : Point) : void
    {
//      clip.x = -offset.x + screen.x - Map.tileSize;
//      clip.y = -offset.y + screen.y - Map.tileSize;
      border.scaleX = size.x / Map.tileSize + 2;
      border.scaleY = size.y / Map.tileSize + 2;
      for each (var southClip in south)
      {
        southClip.y = size.y + Map.tileSize;
      }
      for each (var eastClip in east)
      {
        eastClip.x = size.x + Map.tileSize;
      }
    }

    function mouseMove(event : MouseEvent) : void
    {
      if (partPlace != null)
      {
        partPlace.hoverMenu(event.stageX, event.stageY);
      }
    }

    function createClip(newClip : MovieClip, x : int, y : int,
                        angle : int, isSouth : Boolean,
                        isEast : Boolean) : void
    {
      clip.addChild(newClip);
      children.push(newClip);
      newClip.x = x;
      newClip.y = y;
      newClip.rotation = angle;
      if (isSouth)
      {
        south.push(newClip);
      }
      if (isEast)
      {
        east.push(newClip);
      }
    }

    var type : int;
    var border : MovieClip;
    var partPlace : PartPlace;
    var children : Array;
    var east : Array;
    var south : Array;
    public static var GRASS = 0;
    public static var DESERT = 1;
  }
}
