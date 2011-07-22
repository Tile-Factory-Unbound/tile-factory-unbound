package logic
{
  import lib.Box;
  import lib.ChangeList;
  import lib.Point;
  import lib.Util;
  import logic.change.ChangePart;
  import logic.change.ChangeItem;
  import logic.change.ChangeWorld;
  import ui.GoalView;
  import ui.Sound;
  import ui.View;

  public class Model
  {
    public function Model(newSettings : GameSettings, newView : ui.View,
                          endGame : Function) : void
    {
      settings = newSettings;
      view = newView;
      map = new Map(settings.getSize());
      changes = new lib.ChangeList();
      parts = new Array();
      items = new Array();
      wires = new Array();
      specs = new Array();
      isPlay = false;
      fast = false;
      turbo = false;
      paused = false;
      stepping = false;
      delay = DELAY_MAX;

      goals = new Array();
      view.setModel(settings, changes, map, saveMap, goals,
                    forEachPart, endGame, countParts, countSteps,
                    getCreatedCount, getBrokenCount);

      settings.initMap(changes);
      for each (var spec in settings.getGoals())
      {
        var sprite = new GoalView(spec.bounds, view.getImages());
        var newGoal = new Goal(sprite, spec.bounds.clone());
        var i = 0;
        for (; i < spec.pos.length; ++i)
        {
          newGoal.changeTile(spec.pos[i], spec.color[i]);
        }
        goals.push(newGoal);
      }

      if (settings.isMovie())
      {
        changes.add(Util.makeChange(ChangeWorld.togglePlay));
      }
    }

    public function cleanup() : void
    {
      for each (var part in parts)
      {
        part.cleanup();
      }
      for each (var item in items)
      {
        item.cleanup();
      }
      for each (var wire in wires)
      {
        wire.cleanup();
      }
      for each (var goal in goals)
      {
        goal.cleanup();
      }
    }

    public function enterFrame() : void
    {
      step();
      if (fast || turbo)
      {
        step();
        if (turbo)
        {
          step();
          step();
          step();
          step();
          step();
          step();
        }
      }
    }

    function step() : void
    {
      changes.execute(this, view);
      if (isPlay && (! paused || stepping))
      {
        if (delay == MOVE_FRAMES - 1)
        {
          ifPlaying(moveItems);
          ifPlaying(stepParts);
          ifPlaying(stepRotaters);
        }
        else if (delay < MOVE_FRAMES - 1 && delay > HALF_DELAY - 1)
        {
          ifPlaying(moveItems);
        }
        else if (delay == HALF_DELAY - 1)
        {
          ifPlaying(moveItems);
          ifPlaying(clearForce);
          ifPlaying(stepConveyers);
          ifPlaying(stepGlue);
          ifPlaying(finalizeGlue);
          ifPlaying(checkGoals);
          stepping = false;
          ++stepCount;
        }
        else if (delay > 0)
        {
          ifPlaying(moveItems);
        }
        else if (delay == 0)
        {
          ifPlaying(moveItems);
          ifPlaying(stepItems);
          ifPlaying(finalizeItems);
          ifPlaying(checkGoals);
          ifPlaying(stepSensors);
          ifPlaying(stepLogic);
          delay = DELAY_MAX;
        }
        --delay;
      }
    }

    function ifPlaying(f : Function) : void
    {
      if (isPlay)
      {
        f();
        changes.execute(this, view);
      }
    }

    function stepRotaters() : void
    {
      for each (var part in parts)
      {
        part.stepRotater(changes);
      }
    }

    function stepConveyers() : void
    {
      for each (var part in parts)
      {
        part.stepConveyer(changes);
      }
    }

    function stepParts() : void
    {
      for each (var part in parts)
      {
        part.step(changes);
      }
    }

    function stepGlue() : void
    {
      for each (var item in items)
      {
        if (item.isSticky())
        {
          for each (var dir in Dir.dirs)
          {
            var pos = Dir.step(item.getPos(), dir);
            if (map.insideMap(pos))
            {
              var other = map.getTile(pos).item;
              if (other != null)
              {
                item.checkSticky(other, changes);
              }
            }
          }
        }
      }
    }

    function finalizeGlue() : void
    {
      for each (var item in items)
      {
        item.finalizeSticky();
      }
    }

    function moveItems() : void
    {
      for each (var item in items)
      {
        item.animate();
      }
    }

    function stepItems() : void
    {
      for each (var item in items)
      {
        item.step(changes);
      }
    }

    function finalizeItems() : void
    {
      for each (var item in items)
      {
        item.finalize(changes);
      }
    }

    function clearForce() : void
    {
      for each (var item in items)
      {
        item.clearForce(changes);
      }
    }

    function checkGoals() : void
    {
      var isDone = true;
      for each (var goal in goals)
      {
        if (! goal.check(map, changes))
        {
          isDone = false;
        }
      }
      if (isDone && ! settings.isEditor() && ! settings.isMovie()
          && settings.getId() != "sandbox" && goals.length > 0)
      {
//        Sound.play(Sound.VICTORY);
        view.declareVictory();
      }
    }

    function stepSensors() : void
    {
      for each (var part in parts)
      {
        part.updateSensor(map);
      }
    }

    function stepLogic() : void
    {
      var roots = initLogic();
      while (roots.length > 0)
      {
        var next = roots.pop();
        next.powerChildren(map, roots, !(fast || turbo));
      }
    }

    function initLogic() : Array
    {
      var roots = new Array();
      for each (var part in parts)
      {
        part.resetLogic();
        if (part.isRoot())
        {
          roots.push(part);
        }
      }
      return roots;
    }

    public function addPart(newPart : Part) : void
    {
      map.getTile(newPart.getPos()).part = newPart;
      parts.push(newPart);
    }

    public function removePart(oldPart : Part) : void
    {
      var cell = map.getTile(oldPart.getPos());
      if (cell.part == oldPart)
      {
        cell.part = null;
      }
      var index = parts.indexOf(oldPart);
      if (index != -1)
      {
        parts.splice(index, 1);
      }
    }

    public function forEachPart(f : Function) : void
    {
      for each (var part in parts)
      {
        f(part);
      }
    }

    public function addItem(newItem : Item) : void
    {
      map.getTile(newItem.getPos()).item = newItem;
      items.push(newItem);
      ++createdCount;
    }

    public function removeItem(oldItem : Item) : void
    {
      var cell = map.getTile(oldItem.getPos());
      if (cell.item == oldItem)
      {
        cell.item = null;
      }
      if (cell.itemNext == oldItem)
      {
        cell.itemNext = null;
      }
      var index = items.indexOf(oldItem);
      if (index != -1)
      {
        items.splice(index, 1);
      }
    }

    public function addWire(newWire : Wire) : void
    {
      map.getTile(newWire.getSource()).part.addOutput(newWire);
      map.getTile(newWire.getDest()).part.addInput(newWire);
      wires.push(newWire);
    }

    public function removeWire(oldWire : Wire) : void
    {
      map.getTile(oldWire.getSource()).part.removeOutput(oldWire);
      map.getTile(oldWire.getDest()).part.removeInput(oldWire);
      var index = wires.indexOf(oldWire);
      if (index != -1)
      {
        wires.splice(index, 1);
      }
    }

    public function addSpec(spec : PartSpec)
    {
      specs.push(spec);
    }

    public function removeSpec(spec : PartSpec)
    {
      var index = specs.indexOf(spec);
      if (index != -1)
      {
        specs.splice(index, 1);
      }
    }

    public function startPlay() : void
    {
      if (! isPlay)
      {
        stepCount = 0;
        isPlay = true;
        brokenCount = 0;
        createdCount = 0;
        paused = false;
        stepping = false;
        fast = false;
        turbo = false;
        delay = DELAY_MAX - 1;
        for each (var part in parts)
        {
          part.startPlay(changes);
        }
      }
    }

    public function stopPlay() : void
    {
      if (isPlay)
      {
        isPlay = false;
        while (parts.length > 0)
        {
          ChangePart.destroy(parts[0], this, view);
        }
        while (items.length > 0)
        {
          ChangeItem.destroy(items[0], this, view);
        }
        for each (var spec in specs)
        {
          ChangePart.create(spec, this, view);
        }
        for each (var wire in wires)
        {
          map.getTile(wire.getSource()).part.addOutput(wire);
          map.getTile(wire.getDest()).part.addInput(wire);
          wire.show();
        }
        for each (var goal in goals)
        {
          goal.reset();
        }
      }
    }

    public function isPlaying() : Boolean
    {
      return isPlay;
    }

    public function pause() : void
    {
      paused = true;
      stepping = true;
      fast = false;
      turbo = false;
      view.showWires();
    }

    public function resume() : void
    {
      paused = false;
    }

    public function beginStepping() : void
    {
      stepping = true;
      fast = false;
      turbo = false;
      view.showWires();
    }

    public function setSlow() : void
    {
      fast = false;
      turbo = false;
      view.showWires();
    }

    public function setFast() : void
    {
      fast = true;
      turbo = false;
      view.hideWires();
    }

    public function setTurbo() : void
    {
      fast = true;
      turbo = true;
      view.hideWires();
    }

    public function getMap() : Map
    {
      return map;
    }

    public function getChanges() : lib.ChangeList
    {
      return changes;
    }

    public function smash() : void
    {
      ++brokenCount;
    }

    public function getBrokenCount() : int
    {
      return brokenCount;
    }

    public function getCreatedCount() : int
    {
      return createdCount - countItems();
    }

    function saveMap() : String
    {
      return SaveLoad.saveMap(map.getSize(), specs, wires, goals,
                              settings.getButtonStatus(), settings.getName());
    }

    function countParts() : int
    {
      var count = 0;
      for each (var part in specs)
      {
        if (! part.fixed && ! Part.isItem(part.type))
        {
          ++count;
        }
      }
      return count;
    }

    function countItems() : int
    {
      var count = 0;
      for each (var part in specs)
      {
        if (part.fixed && Part.isItem(part.type))
        {
          ++count;
        }
      }
      return count;
    }

    function countSteps() : int
    {
      return stepCount;
    }

    var settings : GameSettings;
    var view : ui.View;
    var map : Map;
    var changes : lib.ChangeList;
    var parts : Array;
    var items : Array;
    var wires : Array;
    var specs : Array;
    var isPlay : Boolean;
    var brokenCount : int;
    var createdCount : int;

    var delay : int;
    var goals : Array;

    var paused : Boolean;
    var stepping : Boolean;
    var fast : Boolean;
    var turbo : Boolean;
    var stepCount : int;

    public static var MOVE_FRAMES : int = 8;
    public static var MOVE_SPEED : int = 4;
    public static var FRAME_COUNT : int = 2;
    static var DELAY_MAX : int = MOVE_FRAMES;
    public static var HALF_DELAY : int = Math.floor(DELAY_MAX/2);
  }
}
