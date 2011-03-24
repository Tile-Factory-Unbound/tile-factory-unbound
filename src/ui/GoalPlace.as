package ui
{
  import flash.display.DisplayObjectContainer;
  import lib.Box;
  import lib.Point;
  import lib.ui.ButtonList;
  import lib.ui.ImageList;
  import lib.ui.MenuList;
  import lib.ui.Window;
  import logic.Goal;
  import logic.Map;

  public class GoalPlace
  {
    public function GoalPlace(parent : DisplayObjectContainer,
                              newWindow : lib.ui.Window,
                              newImages : lib.ui.ImageList) : void
    {
      window = newWindow;
      window.addClickCommand(clickMap);
      window.addScrollCommand(scrollMap);
      images = newImages;
      select = new SelectClip();
      parent.addChild(select);
      select.visible = false;
      goals = null;
      map = null;
      currentGoal = null;
      currentTile = null;
      isActive = false;
      seekingTiles = false;
    }

    public function cleanup() : void
    {
      select.parent.removeChild(select);
    }

    public function setModel(newGoals : Array, newMap : logic.Map,
                             newRefreshMenu : Function) : void
    {
      goals = newGoals;
      map = newMap;
      refreshMenu = newRefreshMenu;
    }

    function clickMap(pos : Point) : Boolean
    {
      var used = false;
      if (isActive)
      {
        var mapPos = Map.toTile(pos);
        used = selectGoal(mapPos);
        if (currentGoal != null && currentGoal.contains(mapPos)
            && seekingTiles)
        {
          currentTile = mapPos;
          used = true;
        }
        updateSelect();
        refreshMenu();
      }
      return used;
    }

    function selectGoal(pos : Point) : Boolean
    {
      if (currentGoal != null)
      {
        currentGoal.showNormal();
        currentGoal = null;
        currentTile = null;
      }
      var nextGoal = null;
      for each (var goal in goals)
      {
        if (goal.contains(pos))
        {
          nextGoal = goal;
          break;
        }
      }
      if (nextGoal != null)
      {
        Sound.play(Sound.SELECT);
        currentGoal = nextGoal;
        currentGoal.showSelected();
        currentTile = null;
      }
      else
      {
        Sound.play(Sound.CANCEL);
        currentGoal = null;
        currentTile = null;
      }
      return currentGoal != null;
    }

    public function show() : void
    {
      isActive = true;
    }

    public function hide() : void
    {
      isActive = false;
      if (currentGoal != null)
      {
        currentGoal.showNormal();
        currentGoal = null;
      }
      currentTile = null;
      updateSelect();
    }

    public function hasGoal() : Boolean
    {
      return currentGoal != null;
    }

    public function hasTile() : Boolean
    {
      return currentGoal != null && currentTile != null;
    }

    public function toggleGoalHeight() : void
    {
      window.swapLayers(ImageConfig.goalLayer, ImageConfig.goalTop);
      window.swapLayers(ImageConfig.goalTileLayer, ImageConfig.goalTileTop);
      window.swapLayers(ImageConfig.goalTextLayer, ImageConfig.goalTextTop);
    }

    public function hideSelect() : void
    {
      select.visible = false;
      currentTile = null;
    }

    function updateSelect() : void
    {
      if (currentTile != null)
      {
        select.visible = true;
        var pos = window.toRelative(Map.toCenterPixel(currentTile));
        select.x = pos.x;
        select.y = pos.y;
      }
      else
      {
        select.visible = false;
      }
    }

    function scrollMap(pos : Point) : Boolean
    {
      if (isActive && currentTile != null)
      {
        updateSelect();
      }
      return false;
    }

    public function addGoal() : void
    {
      var offset = new Point(map.getSize().x / 2,
                             map.getSize().y / 2);
      var bounds = new Box(offset,
                           new Point(offset.x + 3, offset.y + 3));
      var sprite = new GoalView(bounds, images);
      var newGoal = new Goal(sprite, bounds);
      goals.push(newGoal);
    }

    public function canChangeSize(size : Point) : Boolean
    {
      var result = true;
      var bounds = new Box(new Point(0, 0), size);
      for each (var goal in goals)
      {
        if (! bounds.containsBox(goal.getBounds()))
        {
          result = false;
          break;
        }
      }
      return result;
    }

    public function deleteGoal() : void
    {
      var index = goals.indexOf(currentGoal);
      if (index != -1)
      {
        goals.splice(index, 1);
      }
      currentGoal.cleanup();
      currentGoal = null;
    }

    public function clearGoal() : void
    {
      if (currentGoal != null)
      {
        currentGoal.showNormal();
      }
      currentGoal = null;
      currentTile = null;
    }

    public function deleteTile() : void
    {
      currentGoal.removeTile(currentTile);
    }

    static var MOVE = 0;
    static var EXPAND = 1;
    static var CONTRACT = 2;

    public function modifyGoal(op : int, dir : Dir) : void
    {
      if (op == MOVE)
      {
        currentGoal.move(dir, map);
      }
      else if (op == EXPAND)
      {
        currentGoal.expand(dir, map);
      }
      else if (op == CONTRACT)
      {
        currentGoal.contract(dir, map);
      }
    }

    public function getTileColor() : RegionList
    {
      return currentGoal.getTile(currentTile);
    }

    public function setTileColor(newColor : RegionList) : void
    {
      currentGoal.changeTile(currentTile, newColor);
    }

    public function getGoalOffset() : Point
    {
      return currentGoal.getBounds().getOffset();
    }

    public function selectTiles() : void
    {
      seekingTiles = true;
    }

    public function selectGoals() : void
    {
      seekingTiles = false;
      currentTile = null;
      updateSelect();
    }

    var select : SelectClip;
    var buttons : lib.ui.ButtonList;
    var arrowButtons : lib.ui.ButtonList;
    var tileButtons : lib.ui.ButtonList;
    var window : lib.ui.Window;
    var images : lib.ui.ImageList;
    var goals : Array;
    var map : Map;
    var refreshMenu : Function;
    var currentGoal : logic.Goal;
    var currentTile : lib.Point;
    var isActive : Boolean;
    var seekingTiles : Boolean;
  }
}
