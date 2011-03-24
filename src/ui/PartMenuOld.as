package ui
{
  import flash.display.DisplayObjectContainer;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import flash.system.System;

  import lib.ChangeList;
  import lib.Util;

  import lib.ui.ButtonList;
  import lib.ui.MenuList;
  import lib.ui.Window;

  import logic.change.ChangeWorld;
  import logic.ButtonStatus;
  import logic.Map;

  public class PartMenu
  {
    public function PartMenu(parent : DisplayObjectContainer,
                             newWindow : lib.ui.Window,
                             newWirePlace : ui.WirePlace,
                             newWireParent : ui.WireParent) : void
    {
      window = newWindow;
      wirePlace = newWirePlace;
      wireParent = newWireParent;

      clip = new GameMenuClip();
      parent.addChild(clip);
      clip.part.visible = true;
      clip.wire.visible = false;
      clip.playMenu.visible = false;
      clip.saveMenu.visible = false;

      buttons = new ButtonList([clip.part.all, clip.part.some, clip.part.none,
                                clip.part.mem, clip.part.setButton,
                                clip.part.clear,
                                clip.part.conveyer, clip.part.barrier,
                                clip.part.rotater, clip.part.sensor,
                                clip.part.sprayer, clip.part.mixer,
                                clip.part.copier,
                                clip.part.tile, clip.part.solvent,
                                clip.part.glue,
                                clip.part.triangle, clip.part.rectangle,
                                clip.part.smallCircle, clip.part.circle,
                                clip.part.bigCircle,
                                clip.part.white, clip.part.cyan,
                                clip.part.magenta, clip.part.yellow,
                                clip.part.black]);
      buttons.setActions(click, buttons.glowOver, buttons.glowOut);

      controlButtons = new ButtonList([clip.part.playButton,
                                       clip.part.wireButton,
                                       clip.part.editButton,
                                       clip.part.saveButton,
                                       clip.playMenu.stopButton,
//                                       clip.wire.partButton,
                                       clip.saveMenu.partButton,
                                       clip.saveMenu.copyButton]);
      controlButtons.setActions(controlClick, controlButtons.frameOver,
                                controlButtons.frameOut);

      clip.part.playButton.barText.text = "Play";
      clip.part.wireButton.barText.text = "Wires";
      clip.part.editButton.barText.text = "Editor";
      clip.part.saveButton.barText.text = "Save";
      clip.playMenu.stopButton.barText.text = "Stop";
//      clip.wire.partButton.barText.text = "Back";
      clip.saveMenu.partButton.barText.text = "Back";
      clip.saveMenu.copyButton.barText.text = "Copy";

      clip.back.addEventListener(MouseEvent.CLICK, clickBackground);
    }

    public function cleanup() : void
    {
      clip.back.removeEventListener(MouseEvent.CLICK, clickBackground);
      controlButtons.cleanup();
      buttons.cleanup();
      clip.parent.removeChild(clip);
    }

    public function setModel(newChanges : lib.ChangeList,
                             newSaveMap : Function,
                             newGoalPlace : GoalPlace,
                             isEditor : Boolean,
                             newMap : Map,
                             newMenuList : MenuList,
                             newButtonStatus : ButtonStatus,
                             newPartPlace : ui.PartPlace) : void
    {
      changes = newChanges;
      saveMap = newSaveMap;
      goalPlace = newGoalPlace;
      if (! isEditor)
      {
        clip.part.editButton.visible = false;
      }
      map = newMap;
      menuList = newMenuList;
      buttonStatus = newButtonStatus;

      if (! isEditor)
      {
        var userButtons = [clip.part.all, clip.part.some, clip.part.none,
                           clip.part.mem, clip.part.setButton,
                           clip.part.clear,
                           clip.part.conveyer, clip.part.barrier,
                           clip.part.rotater, clip.part.sensor,
                           clip.part.sprayer, clip.part.mixer,
                           clip.part.copier,
                           clip.part.tile, clip.part.solvent,
                           clip.part.glue,
                           clip.part.triangle, clip.part.rectangle,
                           clip.part.smallCircle, clip.part.circle,
                           clip.part.bigCircle,
                           clip.part.white, clip.part.cyan,
                           clip.part.magenta, clip.part.yellow,
                           clip.part.black, clip.part.wireButton];
        var i = 0;
        for (; i < userButtons.length; ++i)
        {
          if (! buttonStatus.getStatus(i))
          {
            userButtons[i].visible = false;
          }
        }
      }
      partPlace = newPartPlace;
    }

    public function getWireText() : TextField
    {
      return clip.wire.wireText;
    }

    public function stopPlay()
    {
      clip.part.visible = true;
      clip.playMenu.visible = false;
      partPlace.show();
    }

    public function hide() : void
    {
      clip.visible = false;
    }

    function click(choice : int) : void
    {
      partPlace.setPart(choice);
      menuList.changeState(View.PLACE_MENU);
    }

    function controlClick(choice : int) : void
    {
      if (choice == PLAY || choice == STOP)
      {
        clip.part.visible = false;
        clip.playMenu.visible = true;
        partPlace.hide();
        changes.add(Util.makeChange(ChangeWorld.togglePlay));
      }
      else if (choice == EDIT)
      {
//        clip.part.visible = false;
//        clip.editMenu.visible = true;
        partPlace.hide();
//        goalPlace.show();
        menuList.changeState(View.EDIT_MENU);
      }
      else if (choice == SAVE)
      {
        clip.part.visible = false;
        clip.saveMenu.visible = true;
        partPlace.hide();
        clip.saveMenu.code.text = saveMap();
        clip.stage.focus = clip.saveMenu.code;
        clip.saveMenu.code.setSelection(0, clip.saveMenu.code.length);
      }
      else if (choice == WIRE)
      {
        wirePlace.toggle();
        wireParent.show();
        partPlace.hide();
        clip.part.visible = false;
        clip.wire.visible = true;
      }
      else if (choice == PART_WIRE)
      {
        wirePlace.toggle();
        wireParent.hide();
        partPlace.show();
        clip.part.visible = true;
        clip.wire.visible = false;
      }
      else if (choice == PART_SAVE)
      {
        clip.part.visible = true;
        clip.saveMenu.visible = false;
        partPlace.show();
      }
      else if (choice == COPY)
      {
        flash.system.System.setClipboard(clip.saveMenu.code.text);
      }
    }

    function clickBackground(event : MouseEvent) : void
    {
      partPlace.hide();
      wirePlace.reset();
      if (clip.part.visible)
      {
        partPlace.show();
      }
    }

    var window : lib.ui.Window;
    var clip : GameMenuClip;
    var buttons : lib.ui.ButtonList;
    var controlButtons : lib.ui.ButtonList;
    var editButtons : lib.ui.ButtonList;
    var partPlace : ui.PartPlace;
    var wirePlace : ui.WirePlace;
    var wireParent : ui.WireParent;
    var goalPlace : GoalPlace;
    var changes : lib.ChangeList;
    var map : Map;
    var saveMap : Function;
    var menuList : MenuList;
    var buttonStatus : logic.ButtonStatus;

    static var PLAY = 0;
    static var WIRE = 1;
    static var EDIT = 2;
    static var SAVE = 3;
    static var STOP = 4;
    static var PART_WIRE = 5;
    static var PART_SAVE = 6;
    static var COPY = 7;
  }
}
