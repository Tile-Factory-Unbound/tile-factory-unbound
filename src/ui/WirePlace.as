package ui
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Shape;
  import flash.text.TextField;

  import lib.ChangeList;
  import lib.Point;
  import lib.Util;
  import lib.ui.Image;
  import lib.ui.Keyboard;
  import lib.ui.Window;

  import logic.Map;
  import logic.Part;

  import logic.change.ChangePart;

  public class WirePlace
  {
    public function WirePlace(newParent : DisplayObjectContainer,
                              newKeyboard : lib.ui.Keyboard,
                              newWindow : lib.ui.Window) : void
    {
      parent = newParent;
      keyboard = newKeyboard;
      window = newWindow;
      window.addClickCommand(clickMap);
      window.addHoverCommand(hoverMap);
      plan = null;
      source = null;
    }

    public function setModel(newChanges : lib.ChangeList,
                             newMap : logic.Map,
                             newWireText : TextField,
                             newWireParent : WireParent) : void
    {
      changes = newChanges;
      map = newMap;
      wireText = newWireText;
      wireParent = newWireParent;
    }

    public function cleanup() : void
    {
      cleanupPlan();
    }

    public function cleanupPlan() : void
    {
      if (plan != null)
      {
        plan.parent.removeChild(plan);
        plan = null;
      }
    }

    public function reset() : void
    {
      source = null;
      if (plan != null)
      {
        plan.visible = false;
      }
    }

    public function toggle() : void
    {
      if (plan == null)
      {
        show();
        wireText.text = textBegin;
      }
      else
      {
        hide();
      }
    }

    public function show() : void
    {
      plan = new Shape();
      parent.addChild(plan);
      source = null;
      lastPart = null;
    }

    public function hide() : void
    {
      cleanupPlan();
      source = null;
      if (wireParent != null)
      {
        wireParent.showAll();
      }
    }

    function clickMap(pos : lib.Point) : Boolean
    {
      var result = false;
      if (plan != null)
      {
        result = true;
        var mapPos = Map.toTile(pos);
        if (source == null)
        {
          if (map.canStartWire(mapPos))
          {
            Sound.play(Sound.SELECT);
            source = mapPos;
            wireText.text = textEnd;
          }
          else
          {
            Sound.play(Sound.CANCEL);
          }
        }
        else
        {
          if (map.canEndWire(source, mapPos))
          {
            Sound.play(Sound.MOUSE_OVER);
            changes.add(Util.makeChange(ChangePart.addWire, source, mapPos));
          }
          else
          {
            Sound.play(Sound.CANCEL);
          }
          if (! keyboard.shift())
          {
            source = null;
            plan.visible = false;
            wireText.text = textBegin;
          }
        }
      }
      return result;
    }

    function hoverMap(pos : lib.Point) : Boolean
    {
      var mapPos = null;
      var result = false;
      if (pos != null && plan != null && source != null)
      {
        result = true;
        if (pos == null || Point.isEqual(source, Map.toTile(pos)))
        {
          plan.visible = false;
        }
        else
        {
          plan.visible = true;
          mapPos = Map.toTile(pos);
          var color = okColor;
          if (! map.canEndWire(source, mapPos))
          {
            color = badColor;
          }
          plan.graphics.clear();
          var relSource = window.toRelative(Map.toCenterPixel(source));
          plan.x = relSource.x;
          plan.y = relSource.y;
          var dest = window.toRelative(Map.toCenterPixel(mapPos));
          dest.x -= relSource.x;
          dest.y -= relSource.y;
          WireView.drawWire(plan.graphics, new Point(0, 0), dest, color);
        }
      }
      else if (pos != null && plan != null)
      {
        mapPos = Map.toTile(pos);
        var part = map.getTile(mapPos).part;
        if (part != null && ! part.canWire())
        {
          part = null;
        }
        if (part != lastPart)
        {
          if (lastPart == null)
          {
            wireParent.hideAll();
          }
          else
          {
            lastPart.hideWires();
          }
          lastPart = part;
          result = true;
          if (part == null)
          {
            wireParent.showAll();
          }
          else
          {
            part.showWires();
          }
        }
      }
      return result;
    }

    var parent : DisplayObjectContainer;
    var keyboard : lib.ui.Keyboard;
    var window : lib.ui.Window;
    var plan : Shape;
    var changes : lib.ChangeList;
    var map : logic.Map;
    var wireParent : WireParent;
    var source : Point;
    var wireText : TextField;
    var lastPart : Part;

    static var okColor : int = 0x33ff33;
    static var badColor : int = 0xff3333;

    static var textBegin = "Click a Sensor or Logic Piece\nto Add or Remove a Wire";
    static var textEnd = "Click a Destination Piece\nto Add or Remove a Wire.";
  }
}
