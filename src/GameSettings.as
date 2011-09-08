package
{
  import lib.ChangeList;
  import lib.Point;
  import lib.Util;

  import logic.ButtonStatus;
  import logic.change.ChangePart;

  import ui.RegionList;
  import ui.TilePixel;

  public class GameSettings
  {
    public function GameSettings(newSize : lib.Point) : void
    {
      reset(newSize);
    }

    public function reset(newSize : lib.Point) : void
    {
      name = "";
      editor = false;
      movie = false;
      skipToEnd = false;
      id = null;
      winId = null;
      next = null;
      prev = null;
      slides = new Array();
      size = newSize.clone();
      parts = new Array();
      wires = new Array();
      goals = new Array();
      buttonStatus = new logic.ButtonStatus();
      unlocks = new Array();
      stencils = new Array();
      initStencils();
    }

    public function setEditor() : void
    {
      editor = true;
    }

    public function clearEditor() : void
    {
      editor = false;
    }

    public function isEditor() : Boolean
    {
      return editor;
    }

    public function setMovie() : void
    {
      movie = true;
    }

    public function isMovie() : Boolean
    {
      return movie;
    }

    public function shouldSkipToEnd() : Boolean
    {
      return skipToEnd;
    }

    public function setSkipToEnd() : void
    {
      skipToEnd = true;
    }

    public function setId(newId : String) : void
    {
      id = newId;
    }

    public function getId() : String
    {
      return id;
    }

    public function setWinId(newWinId : String) : void
    {
      winId = newWinId;
    }

    public function getWinId() : String
    {
      return winId;
    }

    public function setNext(newNext : String) : void
    {
      next = newNext;
    }

    public function getNext() : String
    {
      return next;
    }

    public function setPrev(newPrev : String) : void
    {
      prev = newPrev;
    }

    public function getPrev() : String
    {
      return prev;
    }

    public function addSlide(newSlide : Slide) : void
    {
      slides.push(newSlide);
    }

    public function getSlides() : Array
    {
      return slides;
    }

    public function setName(newName : String) : void
    {
      name = newName;
    }

    public function getName() : String
    {
      return name;
    }

    public function getSize() : lib.Point
    {
      return size;
    }

    public function getStencils() : Array
    {
      return stencils;
    }

    public function setMap(map : String, loadType : int) : void
    {
      try
      {
        SaveLoad.loadMap(map, size, parts, wires, goals, buttonStatus,
                         stencils, setName, loadType);
      }
      catch (e : Error)
      {
        trace(e.toString());
      }
    }

    public function initMap(changes : ChangeList) : void
    {
      for each (var part in parts)
      {
        var newPart = part.clone();
        changes.add(Util.makeChange(ChangePart.create, newPart));
        changes.add(Util.makeChange(ChangePart.createSpec, newPart));
      }
      for each (var wire in wires)
      {
        changes.add(Util.makeChange(ChangePart.addWire, wire.source.clone(),
                                    wire.dest.clone()));
      }
    }

    public static var STENCIL_COUNT = 5;

    public function initStencils() : void
    {
      stencils = [];
      var i = 0;
      for (; i < STENCIL_COUNT; ++i)
      {
        var region = new RegionList();
        region.addStencil(RegionList.stencils[i]);
        var pixel = new TilePixel();
        pixel.convertFrom(region);
        stencils.push(pixel);
      }
    }

    public function getGoals() : Array
    {
      return goals;
    }

    public function getButtonStatus() : logic.ButtonStatus
    {
      return buttonStatus;
    }

    public function addUnlock(newUnlock : String) : void
    {
      unlocks.push(newUnlock);
    }

    public function getUnlocks() : Array
    {
      return unlocks;
    }

    var editor : Boolean;
    var movie : Boolean;
    var skipToEnd : Boolean;
    var id : String;
    var winId : String;
    var next : String;
    var prev : String;
    var slides : Array;
    var name : String;
    var size : lib.Point;
    var parts : Array;
    var wires : Array;
    var goals : Array;
    var buttonStatus : logic.ButtonStatus;
    var unlocks : Array;
    var stencils : Array;
  }
}
