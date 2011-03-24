package
{
  import flash.events.AsyncErrorEvent;
  import flash.events.NetStatusEvent;
  import flash.events.SyncEvent;
  import flash.net.URLVariables;
  import flash.net.SharedObject;
  import lib.Point;
  import ui.Sound;

  public class Campaign
  {
    public static var TUTORIAL_ISLAND = 0;
    public static var MAIN_ISLAND = 1;

    public static var INACTIVE = 0;
    public static var ACTIVE = 1;
    public static var COMPLETE = 2;

    static function asyncHandler(event : AsyncErrorEvent) : void
    {
    }

    static function netStatusHandler(event : NetStatusEvent) : void
    {
    }

    static function syncHandler(event : SyncEvent) : void
    {
    }

    public static function init() : void
    {
      disk = SharedObject.getLocal("tile-factory");
      disk.addEventListener(flash.events.AsyncErrorEvent.ASYNC_ERROR,
                            asyncHandler);
      disk.addEventListener(flash.events.NetStatusEvent.NET_STATUS,
                            netStatusHandler);
      disk.addEventListener(flash.events.SyncEvent.SYNC,
                            syncHandler);
      load();
      var children = campaign.descendants("level");
      for each (var child in children)
      {
        var levelId = String(child.@id);
        levelXml[levelId] = child;
        levelTitles[levelId] = String(child.@title);
        if (levelState[levelId] == null)
        {
          levelState[levelId] = INACTIVE;
        }
      }
      save();
    }

    public static function reset() : void
    {
      var children = campaign.descendants("level");
      for each (var child in children)
      {
        var levelId = String(child.@id);
        levelState[levelId] = INACTIVE;
      }
      for each (var tutorial in LevelMenu.tutorialBase)
      {
        levelState[tutorial] = ACTIVE;
      }
      for each (var main in LevelMenu.mainBase)
      {
        levelState[main] = ACTIVE;
      }
      save();
    }

    static function load() : void
    {
      try
      {
        if (disk.data.done == true && disk.data.version == 0)
        {
          if (disk.data.levelState != null && disk.data.levelState != "")
          {
            levelState.decode(disk.data.levelState);
          }
          if (disk.data.mute == true)
          {
            Sound.toggleMute();
          }
          if (disk.data.muteMusic == true)
          {
            Sound.toggleMusic();
          }
          if (disk.data.levelSaves != null && disk.data.levelSaves != "")
          {
            levelSaves.decode(disk.data.levelSaves);
          }
          if (disk.data.island != null)
          {
            island = disk.data.island;
          }
          if (disk.data.islandX != null && disk.data.islandY != null)
          {
            islandPos = new Point(disk.data.islandX, disk.data.islandY);
          }
        }
      }
      catch (e : Error)
      {
        reset();
      }
      if (levelState[LevelMenu.tutorialBase[0]] == INACTIVE)
      {
        reset();
      }
    }

    public static function save() : void
    {
      try
      {
        disk.data.done = false;
        disk.data.version = 0;
        disk.data.levelState = levelState.toString();
        disk.data.levelSaves = levelSaves.toString();
        disk.data.island = island;
        disk.data.islandX = islandPos.x;
        disk.data.islandY = islandPos.y;
        disk.data.mute = Sound.isMute();
        disk.data.muteMusic = Sound.isMuteMusic();
        disk.data.done = true;
        disk.flush();
      }
      catch (e : Error)
      {
      }
    }

    public static function saveLevel(id : String, map : String)
    {
      levelSaves[id] = map;
      save();
    }

    public static function winFirst() : Boolean
    {
      return winAll(["conveyer-demo"]);
    }

    public static function winTutorial() : Boolean
    {
      return winAll(LevelMenu.tutorialIds);
    }

    public static function winMain() : Boolean
    {
      return winAll(LevelMenu.mainIds);
    }

    static function winAll(list : Array) : Boolean
    {
      var result = true;
      for each (var current in list)
      {
        if (current != "" && levelSaves[current] < COMPLETE)
        {
          result = false;
          break;
        }
      }
      return false;
    }

    static var levelXml = new URLVariables();
    public static var island : int = 0;
    public static var islandPos : Point = new Point(0, 0);
    public static var levelTitles = new URLVariables();
    public static var levelState = new URLVariables();
    public static var levelSaves = new URLVariables();
    static var disk : SharedObject = null;

    public static function parse(settings : GameSettings,
                                 levelId : String) : Boolean
    {
      var found = false;
      var child = levelXml[levelId];
      if (child != null)
      {
        settings.setId(levelId);
        settings.setWinId(levelId);
        if (String(child.@next) != "")
        {
          settings.setNext(String(child.@next));
        }
        if (String(child.@prev) != "")
        {
          settings.setPrev(String(child.@prev));
        }
        parseLevel(child, settings);
        found = true;
      }
      return found;
    }

    static function parseLevel(level : XML, settings : GameSettings) : void
    {
      var movie = level.child("movie");
      if (movie.length() > 0)
      {
        settings.setMovie();
      }
      var unlocks = level.child("unlock");
      for each (var unlock in unlocks)
      {
        var name = String(unlock.@name);
        if (name != "")
        {
          settings.addUnlock(name);
        }
        else
        {
          trace("Empty name: " + String(level.@id));
        }
      }
      var slides = level.child("slide");
      for each (var slide in slides)
      {
        var text = slide.toString();
        var pos = null;
        if (String(slide.@x) != "" && String(slide.@y) != "")
        {
          pos = new Point(parseInt(String(slide.@x)),
                          parseInt(String(slide.@y)));
        }
        var isPixel = false;
        if (String(slide.@pixel) == "true")
        {
          isPixel = true;
        }
        var align = String(slide.@align);
        if (align == "")
        {
          align = "top";
        }
        settings.addSlide(new Slide(text, pos, isPixel, align));
      }
      var map = level.child("map").toString();
      var saveMap = levelSaves[String(level.@id)];
      if (saveMap != null)
      {
        settings.setMap(map, SaveLoad.LOAD_LEVEL);
        settings.setMap(saveMap, SaveLoad.LOAD_SAVE);
      }
      else
      {
        settings.setMap(map, SaveLoad.LOAD_ALL);
      }
    }

    static var campaign =
    <campaign>
<!--
    <level number="0">
      <movie />
      <slide>This is a demo solution to see most of the parts in action.</slide>
      <map>
eNotkGFyJCEIhRH1gYjO9Famk/zKUXKPnHZv1vt6K+In1FMQLS
KfD/k5IfEeEp9b4kMyHmvHth1vUmOJRRbbWTLSluciu4wMAlJq
mIA4mWSFYYc5SbLJQ8IWmWQQI52IkhZQ69Vcqw1UH2onlXAFOL
0Cu7Kk9unaEWrFQ8UFjPuctddkoYketXXUzrSB4szX2gpcR2Oh
1run1bFMQ6Oh3moBaunQbGgGzNYrumIl7I8pLIHMRqfCCyK9xf
bGX4HMxb6yDeO5AwtP2+Ow0Cc2Dt84R9q7xzjZ7GtsvHzLlw+7
zc3vyIOPKC5Bkrb5sGI+/N53fgY9nFpdlrce8MJW0dGZNeeKRe
a9rtVgyyzmYQcOe4Jmp59s4DVoXt7wMURfdtr197pu5Fvkv+f4
la7v3/jWmjyuf6s4KBQ=
      </map>
    </level>
-->

    <level id="sandbox" title="Sandbox">
      <map>
eNpjZGCQlGQAAfb///8DAAg/Azg=
      </map>
    </level>


    <level id="conveyer-demo" next="conveyer" title="Conveyers">
      <movie />
      <slide align="middle">Welcome to Tile Factory! Click next.</slide>
      <slide x="2" y="2">This is a goal. Move at least 5 white tiles here.</slide>
      <slide x="5" y="4">This copier is duplicating the white tile to its right.</slide>
      <slide x="4" y="4">This conveyer pushes tiles to the left.</slide>
      <slide x="3" y="4">Tracks like this show where a conveyer will push.</slide>
      <slide>You can use conveyers to push tiles to the goal.</slide>
      <map>
eNptxksKgDAMRdF8XhIMVbfgUgTHLqMDJxYcFNy9XYAXDlym5W
h3r299trP1q0ZQFsM6O9KBNcwyTNMFJYQzXAfLSTSJRQ3MDIwV
+m//ADzBBwI=
      </map>
    </level>


    <level id="conveyer" prev="conveyer-demo">
      <unlock name="jam-demo" />
      <slide align="middle">Now you try it.</slide>
      <slide x="40" y="564" pixel="true">Click on the conveyer button to pick one up.</slide>
      <slide>You can click a rotate button to turn your conveyer before placing it.</slide>
      <slide x="1" y="2">Click on the factory floor to place it.</slide>
      <slide>You can click on a piece to move it again.</slide>
      <slide x="360" y="500" pixel="true">When you have finished, click the Test tab to try it out.</slide>
      <slide>Once the test is successful, you will be able to move on to the next level.</slide>
      <map>
eNptiUEKgFAQQrU/M8bQ70xBZ2lb0CLo9k2tU/QJEuN67Nd2b6
eEPpG9EylUBlbezWyIuTFS7qmwlBWtGJ6ok+WvSWsK0A3/Wh7P
FAUi
      </map>
    </level>


    <level id="jam-demo" next="barrier-demo" title="Barriers">
      <movie />
      <slide>Be careful! Your tiles are fragile.</slide>
      <slide x="10" y="4">If two tiles collide, they will both break.</slide>
      <slide x="3" y="4">A tile pulled in multiple directions will also break.</slide>
      <map>
eNptiUEOgEAMAqHdti6umvj/v2q9CyEzCQT2wr0Y62BqzeZMJc
dZlioL1fatHd/a1VTTqSoqPZcDcvDEAMBuZ0ZrWHIOsAw/MUZ/
/vsNXM8LCC4DaQ==
      </map>
    </level>


    <level id="barrier-demo" next="barrier" prev="jam-demo">
      <movie />
      <slide x="4" y="2">Barriers stop conveyers.</slide>
      <slide>Use them to prevent conveyers from interfering with each other.</slide>
      <map>
eNptjEsKw1AMA+VPrFiNm13vf9PmvX0EAwMDMuAj/Magaegym6
ttCIgw0TfLz81ybaBqv8v8y3SxXBWYIoZRIksdqWYKzmyLNPPK
Xo888DLPY7V4bYn7/wAtqwPU
      </map>
    </level>


    <level id="barrier" prev="barrier-demo">
      <unlock name="sprayer-demo" />
      <slide>Hint: Type WASD to change orientation and space to change power when placing a piece.</slide>
      <map>
eNptjMENgDAMA+2WtE0oHYpNePDg2wkZDfMGW6fEsRSi7sec1z
l9xejk2MCoQFQKJM0Una67Kzfll9AekWGiDCwwFNlgpPBkpTlY
9OkrS83UZfzrfgBNUwWB
      </map>
    </level>


    <level id="sprayer-demo" next="sprayer" title="Sprayers">
      <movie />
      <slide>Tiles can be painted different colors.</slide>
      <slide x="6" y="1">You must send tiles of the specified color to the goal.</slide>
      <slide x="4" y="2">Sprayers use a can of paint to color a tile.</slide>
      <slide x="4" y="3">Paint is loaded into the back of the sprayer.</slide>
      <slide x="4" y="1">The next tile to come along the nozzle will be sprayed.</slide>
      <slide x="4" y="5">This copier is duplicating the can of paint below it.</slide>
      <slide>The sprayer must be constantly supplied with new paint to operate.</slide>
      <map>
eNpdwzsOglAUBNCZx/3g5IqhsXYx7IAVWFAaDZ2rx0frSQ5R62
d/frf9sWyv95iYZa3uFirzisapyOkKKpMKs0pCiXNTsh+8D6Wf
XRen0Jzmzs4xDmDw6PDHcDt+JVELqw==
      </map>
    </level>


    <level id="sprayer" prev="sprayer-demo">
      <unlock name="sensor-demo" />
      <slide>Now you must deliver 5 black tiles to the goal.</slide>
      <map>
eNpdiTsOg1AMBP3bNbJeSJ1zcQIKekSq3C43SwwlI80WsyrTsh
/rZzvemTI/aJXU1iudlWC9gjUCY8Ce6eh22j+0nJidLAmCJ73R
wlQtIGr+uyEX8f0DKO0WMA==
      </map>
    </level>


    <level id="sensor-demo" next="sensor" title="Sensors">
      <movie />
      <slide x="8" y="2">Place sensors on top of conveyer tracks.</slide>
      <slide>Sensors power on whenever something is over them.</slide>
      <slide>You wire the sensor to conveyers, copiers, and sprayers.</slide>
      <slide>The sensor activates them only when it is covered.</slide>
      <slide x="8" y="2">This sensor is wired to a copier.</slide>
      <slide x="8" y="9">So this copier creates a new can of paint whenever the tile passes it.</slide>
      <slide x="2" y="4">This sensor is wired to a conveyer.</slide>
      <slide x="8" y="6">And this one is wired to the same conveyer.</slide>
      <slide x="7" y="9">So this conveyer only activates when the tile passes those sensors.</slide>
      <slide x="3" y="7">This sensor is connected to the tile copier.</slide>
      <slide x="1" y="1">So a new tile is created only when the previous tile reaches it.</slide>
      <map>
eNo1TVsKwkAQm5ndeWW77a/45WG8gWfopxb0/tQBMRDyIBCm8d
hfn+N9u+/PA6DrwrxOYjgRnIskpQITXi14WrTNpE0TrayVfXN2
XDKxRA7PgEfAPAc0wnsimyPDkNJLBakJ0pCoovY1bc6sqcFsPY
ml3n84C3/faTu/ZDcM9Q==
      </map>
    </level>


    <level id="sensor" prev="sensor-demo">
      <unlock name="violet" />
      <unlock name="stencil-demo" />
      <slide align="middle">Now you try it.</slide>
      <slide x="265" y="500" pixel="true">Click the Wires tab to set up wires between pieces.</slide>
      <slide x="3" y="2">Click this sensor to start a wire.</slide>
      <slide x="4" y="5">Click the paint copier to wire it in.</slide>
      <slide>Now the paint will only be produced when a tile arrives.</slide>
      <slide x="5" y="2">Click this sensor in wire mode to start another wire.</slide>
      <slide x="1" y="2">Click on the tile copier to wire it in.</slide>
      <slide>This slows down the rate of tile production.</slide>
      <slide>A new tile will be created only when the old tile passes this point.</slide>
      <slide>Remove a wire in the same way. Click the source, then click the destination.</slide>
      <map>
eNpdw0EOQEAMBdDfdtqOnyG2zuUMtiRc0M0YWy95gli3/TrOmp
hHKBPSG5cSbMVrE53Sg2lfZ3ov1gtDdWKxNphycCUgjmqQkOcH
XUHcL5AOFRM=
      </map>
    </level>


    <level id="violet" title="Violet">
      <map>
eNpNw7ERgCAMBdAfCQRjsLV1IStnoJU7WNDNNHa+u0ewo/W6n/
UarY8isAJWQfBRTWg24lUyqaQvVLKn6INuAgVIqTBomeAehx9G
ul9WJgr2
      </map>
    </level>


    <level id="stencil-demo" next="stencil" title="Stencils">
      <movie />
      <slide x="5" y="6">Stencils cover up part of a tile.</slide>
      <slide x="9" y="2">When you paint a tile, only the uncovered section is painted.</slide>
      <slide x="13" y="6">You can use solvent to remove stencils.</slide>
      <slide>Stencils and solvent are both applied with a sprayer.</slide>
      <slide>The covered portion of a tile will always remain unchanged.</slide>
      <map>
eNpNzb0NAjEMBWDbie3E5+QOKGhhFzZATIAokPhpmIop2Aycji
d9etZrjODH1+Vxvt52h8v9uVHYNyBTwJDMKxdH6mpiWgY2tYAp
oG2r2MKxyxB7HsScuajH7bH36B5b49KbmBB14+RWQ0teE1nVMM
XfVfRMBjkRs1LliRrPhIQzrjPgQjBy+r7hLxnk8wOZ2Qwd
      </map>
    </level>


    <level id="stencil" prev="stencil-demo">
      <slide>Hint: Use the Tile Lab to figure out what order to place your stencils.</slide>
      <unlock name="imperial" />
      <unlock name="rotater-demo" />
      <map>
eNo9xkEOgkAMheHXmem01EIkuuBeHIGwMDGuPCA3g3ahL/nzPo
Ks3/2zvd5PwTKimFOZvLHOrdui3VxZJ493VqndpLIJZ2HJwkMW
vmXhMQuDTCir4WoA3enRQHPBf+f5U0M/Lr45COc=
      </map>
    </level>


    <level id="imperial" title="Imperial">
      <map>
eNolyUEKQjEMhOE/WNvXSa24U2/kMVy4EBTEE3qzZ6IJHxkyxn
J5vm7v+/Ux9px3oGHMk1cdHR0omizxKyGuqg/hzU1Naavmqem3
Fj/SJnKKjpRd6pG7wBb3ifUB65py/hkK9fMFrLoRaQ==
      </map>
    </level>


    <level id="rotater-demo" next="rotater" title="Rotaters">
      <movie />
      <slide>Stencils and tiles can be rotated.</slide>
      <slide x="14" y="2">Place a rotater on a track and it will rotate any tile passing over it.</slide>
      <map>
eNpdjUsOAkEIRIGG7mmkGT+Ja1eexBN4AxcujYnxgB7MZKzZSv
JSBRSBKa7P9+19f50u98fz0Og8SLwRg+LRbQqWbF69TSvmzQEX
gIwpcmtvHgwf8IFcQrN6DJtyVK8i6VrCOxglehHvDWzwawedxf
ekyGlOBaTkseNOsVPMTZKsCGuTbhsZNguLqgrPvFfirSzLd6G/
UqqfH8iWDq4=
      </map>
    </level>

    <level id="rotater" prev="rotater-demo">
      <slide>Hint: Shift-click to place more than one of the same piece</slide>
      <unlock name="pyramid" />
      <unlock name="star" />
      <unlock name="mixer-demo" />
      <map>
eNpVxkEOg0AIheHHzDBQRKPRGM/VG3TRtUnjAXuzFpYS/ryPIM
/zel3vzyY4RhRzKpM31qV1c2WdPNZZpXaTyiachSULP7LwkIXH
LAwyoayGq+3aDaCZ1gZayg+Iv1+DfP/SVwj1
      </map>
    </level>

    <level id="pyramid" title="Pyramid">
      <map>
eNo1zbENQjEQA1CfCLp8O4RfIdExEg0DINFQ0NCxElOwGfgKLn
qKc5KVQJ5fz+vjfht7nHYAR2Ae1TnRnZv5ZtNgV2phsmyYKltn
i2CieBfFO5R0Lu6gej5Krmhc1XgQ/HaP4T8gILo0Ecv4ei5v4K
+mIT8/HSsO6g==
      </map>
    </level>

    <level id="star" title="Star">
      <map>
eNpdjcsNAjEMRGdW2Thr7HDJHrjTB0VQAS0gCqQ0xlcsPfnJHw
3Rnp/X+zpxPy39xvSZ6WuHJ+FBZjBG7DzC1DOGbXDb6IYUIS/k
TbOm3VHIu2Zdu1HIo5DPon51B/rq8GViKK9Xjhg8AF44Gxjb46
+garDvD50cC2w=
      </map>
    </level>

    <level id="mixer-demo" next="mixer" title="Mixers">
      <movie />
      <slide x="4" y="5">Mixers combine paint colors to make new ones.</slide>
      <slide>There are 16 different paint colors.</slide>
      <slide>The paint model is based on the CMYK color process.</slide>
      <map>
eNpNizsOAjEMRO2JP4kTsiXQUXESWo6xBQVCouL24HRYeprnH1
PcH5/9fbntz9cWdD2ixclaDKt1oNYuPgw+zXw7EGIwpgHTD8sl
ziTRRXMmeaPDVcJUZ1gZZohmEq1kdoR5/nEL5xpeFum6SPdFOm
nuEyqZCXEmB6mJoYClALXAageDO08hHqCs71+tXmj7/gBonBXL
      </map>
    </level>

    <level id="mixer" prev="mixer-demo">
      <slide>Hint: Use the Dye Lab to figure out how to mix your colors.</slide>
      <unlock name="monaco" />
      <unlock name="some-demo" />
      <map>
eNo1hrENgDAMBO0oKG/jgESBWIoxKGipGI/N4F1w0ulOZdjP+7
hml2Xr5tGBMKArXxEN5g3w5ik/Uv6U8iXlF7bAVzMX0VGnKhrl
JUL+JlXm5wNOIw24
      </map>
    </level>

    <level id="monaco" title="Monaco">
      <map>
eNpFjUEOwjAMBNeladONUxpAAu58h0cg7vSL/Kxdc8HSaEY+2I
bhuX5e7/XieFxr4a0VemP2ylxNbXSfmO9T4egBOc6BegnUp0DN
QJ3lLEOG3Mkd2ZI8BNr1ge4n5rmCXm0aZ+iu6UcAArZ05wRrB/
xm2/4APY7fHaplDxU=
      </map>
    </level>

    <level id="some-demo" next="some" title="Some">
      <movie />
      <slide x="5" y="5">The Some piece helps you control power.</slide>
      <slide>It powers on if any of its incoming wires are powered.</slide>
      <slide x="5" y="3">This sensor on the north path is wired to the Some piece.</slide>
      <slide x="5" y="7">So is this sensor on the south path.</slide>
      <slide x="10" y="5">And the Some piece is wired to the paint copier.</slide>
      <slide>So the copier will create paint when either of these sensors is pressed.</slide>
      <map>
eNptjcsNQjEMBO04ju3NhzM36IUOqOEdn+iBxsG5IlYaaaVZ2U
zxfJ3H7XGcrzHoPljWJMFgw4D2a1dYrzBsWvYGeJvwOiYZjB1G
m3S8yR1tSvaCUEsErLrCBeF5pdhqRZYF0MJmCxkt9GKWv4JBqq
aqkijUhc2NpTj3Shzl8xPKuPeeLv65Su39BUggKIc=
      </map>
    </level>

    <level id="some" prev="some-demo">
      <unlock name="two-triangles" />
      <unlock name="none-demo" />
      <slide>Hint: Press Delete or Backspace to trash a part after picking it up.</slide>
      <map>
eNptiUEKgDAMBDdptXUTFTz5L9/gUfyjH9MU9ObCsAMjyNt57O
5YXNI0ItGF7uysWGZho2exnqMYizKIRyNcoqOh4crVOgJaxTJk
ULy7Y5/XahZt+GsZ8/UAwEwNDA==
      </map>
    </level>

    <level id="two-triangles" title="Two Triangles">
      <map>
eNpNjMEKwjAQRHdLzTbTjU17ELx58JPaD/AgIoiCHvwnP8Mf09
mD4ITHJjOzUSnz87ab7+fD9XQ5PqYie1ctRQWuvbul3roVzAKD
dYaiDmt6wikB76JE6AWKjSRsc4Jl7iHgyQZHwnpM8Mp/R/o1YD
Yaase+8i1E6Qn7miDSDDq1orX5hF6y/BBqyJMzw/IfkFArw/sL
RYIdGg==
      </map>
    </level>

    <level id="none-demo" next="none" title="None">
      <movie />
      <slide x="6" y="3">The None piece activates when no incoming wires are powered.</slide>
      <slide>You can use it to manage crossing conveyers and split up tiles.</slide>
      <slide x="7" y="4">This sensor is wired to the None piece and two cross conveyers.</slide>
      <slide x="4" y="4">The None piece is wired to the forward conveyer.</slide>
      <slide>So when the sensor is pressed, the forward conveyer stops and the cross conveyers start.</slide>
      <slide>And if the sensor is clear, only the forward conveyer runs.</slide>
      <slide>This means that there won't be a jam and the pieces are split into two directions.</slide>
      <map>
eNptiUkOwzAMA7VQZKzYzqX//2rr3kOAGAzGzdawz3RsBnYwN4
Fm1aRy6UIP/T0nKzZVi+LWzdYdvez0RMuy5edWh9VWglKoQyYT
SDhi1LzMm/ay4ROnxVuDPd8fUNEEGA==
      </map>
    </level>

    <level id="none" prev="none-demo">
      <unlock name="all-demo" />
      <unlock name="glue-demo" />
      <slide>Hint: Levels are open-ended. You can often do them without even using the new part presented.</slide>
      <map>
eNptiksOgDAIRAdKS8VCExd6/8t4LcXEhQsneZnMh4C5YBuOqc
Gmrqah5oF0yvwgCWfXbXifw8s6vK4aT9/y12yPakcUA5iqdBC3
6xU+IhLJjf82wTxvUTcT2Q==
      </map>
    </level>

    <level id="all-demo" next="all" title="All">
      <movie />
      <slide x="6" y="4">This sensor is wired to the conveyer on its left.</slide>
      <slide>That groups the tiles into pairs as they move past.</slide>
      <slide>To split up the pairs, we use an All piece.</slide>
      <slide>The All piece powers on only when every incoming wire has power.</slide>
      <slide x="7" y="4">This sensor is wired to the All piece.</slide>
      <slide x="8" y="4">This sensor is also wired to the All piece.</slide>
      <slide x="9" y="6">The All piece powers on when both sensors are pressed.</slide>
      <slide x="7" y="5">It is wired to the conveyer here.</slide>
      <slide x="8" y="5">And the conveyer here.</slide>
      <slide>So both conveyers are turned on at the same time when both sensors are pressed.</slide>
      <slide>This splits the tiles so both goals can be supplied.</slide>
      <map>
eNptjDsOAkEMQzMzsTPJfLal5CpIXIVuEfevIPRr6cmWLLtIf5
zn/fl6f7bLjRV7CWIWbELDmVjSNcw1aJi0NtnTe9u0ujnaEue2
WcOGhQNBYhpbmOSu/GFmhpAKNXX2xPMuE4CCGmWplFHlQoHVs+
NVp3J8f98oB6s=
      </map>
    </level>

    <level id="all" prev="all-demo">
      <slide>Hint: You can toggle the power on copiers and other fixed parts by clicking on them.</slide>
      <map>
eNpNicsNgCAQRGcR2GVATLxoO/Zjn5aly8GEl7xkPoLluu+tYl
+R2CR1RaTKMFOReRp5GKiFbqHq0LOKO/ahsFmxZlKAUKVHSAtw
XgcTVTv9s7/Pf8T2fI+LDLA=
      </map>
    </level>

    <level id="glue-demo" next="glue" title="Glue">
      <movie/>
      <slide x="12" y="2">Some goals are mosaics which must be glued together.</slide>
      <slide x="0" y="4">Spray glue on a tile to make it sticky.</slide>
      <slide x="5" y="4">Sticky tiles have a purple border.</slide>
      <slide>When a sticky tile moves next to another tile, they are joined into a mosaic and are no longer sticky.</slide>
      <slide>The entire mosaic is fragile.</slide>
      <slide x="9" y="6">If pieces are pulled in different directions, the whole thing collapses.</slide>
      <map>
eNqNjoeNBDAIBMGBsCY08v2398d1cEijIVgGJmrQXzBV8EGwlZ
JCeaA7HmiPB+IxQ9YpnFOyrORayN2TU/oVOPbMV6ksaAmaDpJs
IGSNy9GliNQX6R1pjact4e3PoSkQ9xDMv2E9Vat+e2OaOX/fbJ
BcmXM302DYOYvTnqfy47q0YsWmH+NQ/38A9WAHtg==
      </map>
    </level>

    <level id="glue" prev="glue-demo">
      <unlock name="white-tee" />
      <unlock name="black-box" />
      <unlock name="mem-demo" />
      <slide>Try it out.</slide>
      <map>
eNpNikEOwkAMA51tQion2woQCA78/yk8C3zooZZGY1k24Nn4tL
PbbbYFExemCbgsFghjhhzyUoLqcpDTS4A7gq8qvmexi2tPrkl9
qG8lU2O2+iZvJGBXezjGbdwHjvyO4JTz5ti/f0DFFSY=
      </map>
    </level>

    <level id="white-tee" title="White Tee">
      <map>
eNqtze0NgyEIBOAjeSt6Av7Q7tD9l+haPXcoyRMI4cOA98InDB
VWFbtWbCyH0U22nCtVC8SSiRIwz1VccK4jhBRj+wzaCHMGszu6
9gRNWQZEd6fyvPfV25dmjswS/RpXEbD+yoFnNLapOfw5HqzvD4
0KB1E=
      </map>
    </level>

    <level id="black-box" title="Black Box">
      <map>
eNqlzTEOAzEIBMBFuhznNeDCTnE/yP8/kWcl6zZtVhqBEAIDng
OvMFRYVcwaMTEcRjeZsrZULxBLJkrAXFtxEFKM6T1oLcwZzMtx
aV9wqkqD6F5X7fuuZnPTzpJeoh9tK97LecMJWHtkw8Gzn93pn5
9A+Wd2YLy/J8lHKQ==
      </map>
    </level>

    <level id="mem-demo" next="mem" title="Memory">
      <movie />
      <slide>Memory pieces deliver the power they get after waiting one second.</slide>
      <slide x="2" y="5">You can wire them up in a circle to act as a precise timer.</slide>
      <slide>Make sure some start up powered and some not.</slide>
      <slide x="7" y="1">You can also use them to delay power if you can't put a sensor in the right spot.</slide>
      <slide x="10" y="1">The sensor is wired through this memory so the copier is activated one second after it is pressed.</slide>
      <slide>Memory pieces can be useful in many situations.</slide>
      <map>
eNptjEsOAzEIQ/kUSEwmWXfX+19y6tlWxXrCWBYqckE+7gH3hF
tst9xpupfqvkSRQy9MO6ut38tQIiglQq9kKaofnN4xS+HgPSYw
41S/mJNO7sTq6LMCcxhxCHyT8PS0R2HhYanKR1Qbi84i1aGVgN
ioMe6fEc6/7CXn/gIJXiXi
      </map>
    </level>

    <level id="mem" prev="mem-demo">
      <slide>Try it out.</slide>
      <unlock name="set-clear-demo" />
      <unlock name="obelisk" />
      <unlock name="sunrise" />
      <map>
eNpdxUEOwyAMRNGxiw2xgAQaJbve/zY9Eh11147m6wlwZ7yqaL
82j9489uFRzUrdWGPDSoNGhkQWhgdlyZhHduq00EKDBq200k47
PehBJ50ewzwAmXIl6FNPxVr43/r+dwn7+wOCDwlT
      </map>
    </level>

    <level id="set-clear-demo" next="set-clear" title="Set & Clear">
      <movie />
      <slide>You can use memory to permanently store signals using the Set and Clear piece.</slide>
      <slide x="6" y="4">This Memory has no incoming wires. Instead, it is next to a Set piece and a Clear piece.</slide>
      <slide x="5" y="4">Set pieces turn on adjacent Memories when they are powered on.</slide>
      <slide x="7" y="4">Clear pieces turn off adjacent Memories when they are powered on.</slide>
      <slide x="4" y="2">When the block passes the first sensor, this activates the Set piece which turns on the Memory.</slide>
      <slide x="7" y="2">The memory stays on until the block passes the second sensor, activating the Clear piece.</slide>
      <slide x="1" y="6">When the memory turns on, it activates the second copier continuously.</slide>
      <slide>Set and Clear can make your job easier, but you can always do without.</slide>
      <map>
eNptyzEOwzAMQ1GKoaVacZwt979py+4R8PAHQgHcE88K7iT3bP
aUFftItYZ6lDqZe0X2hT92IbrCcLiG4RrKtSuNDYlDxVLK7wzy
jC3EIl7uHPvjLd824f7+AFOXBCE=
      </map>
    </level>

    <level id="set-clear" prev="set-clear-demo">
      <slide>Try using set and clear to pass this level.</slide>
      <map>
eNotjEEKw0AMAyUaaq/WmxySbEr//8D+IFWhA8McZEzgangHqS
AUCDc0kNoBTUGvgq70Fj9919zmdre7wx1UJVvJloVlrjH97wzV
mX2dKYD7Yz7BY7nNZj4GfxZs9xfPogzf
      </map>
    </level>

    <level id="obelisk" title="Obelisk">
      <map>
eNqVikEKwzAQA7Xg1omsdXqJSaDf6if7yVS+FXqqYBjtogCOju
fewDPBB8BEUpCEWNVMxlojWUMGJli73W3atGVr3t7RO03c+0RU
06LU0ltyyyQQezmIMm7jPupY8JXXGz+5nH9+Bdv1AYAqEtg=
      </map>
    </level>

    <level id="sunrise" title="Sunrise">
      <map>
eNotzVkOwyAMBNBxFhyG7aNpk96iN8jVezM6VEF6whpsY8BZ8X
kF8CD4ruCJxFYLKwt3zCxwZvOaLTEzb7kOFjMliM10BNmEkumx
0JMUaQNUS5IoavRVMMlCN82YZk07TLtsZHpbTb0SJUmRNqi/SB
p/ZQL2CEfEtPvT+7f3ARfwv3XuqF93PbIFrf8ArJwe7A==
      </map>
    </level>

// ****************************************************************************

    <level id="rainbow" title="Rainbow">
      <map>
eNpNykEOwjAMRNFxhQiZOK5ok1KuwJYtt+dIHCAMggWWnr5k24
Btxm1j8FKE4F7Aq4eAcw9GB5caXAG2ClYEvVp2g1pPTini0qJ4
Q3HXvQg/fxEJE5MJqio5RA011C7tU1MlIGpWs3GH0c0I2PnYM6
Y1Lek5xnjJA8Ad3xm/Jf6WB8zjDRJDGJg=
      </map>
    </level>

    <level id="crown" title="Crown">
      <map>
eNp1j0tuhDAQRMsowqZo/FFGfBaYXCh35makjGYxLIL09Nxtu3
A74CfhN2Uw5cgCcUS+HPiq4ATP6fCMAxiXSO8m4UUvgnD0QQyC
Imk/iyKS6iyK2Bqgn9VfxCpqQzlVeVVZ1dEON9iO0VZ5EQW01O
pIm+NoxxRsbw6THb1ZUT+ppvqD6FRDhvbhzaAzUE6nnKAc6g2d
/ts5zaoZnWatbWb1d/V3x2WI3KhZR9WjHOQgz+392l/AbQUBF/
tvok8hhxKSz7543N+Fp+/19fQ/B6/z6fvGeX76feH89BfS9Qd2
gSWA
      </map>
    </level>

    <level id="czech" title="Czech Flag">
      <map>
eNoVjU0KAjEMRr+MbdOGps6g+LMR7+INhF7AYUDBhRs3HslTeL
OaJjxeCOELoVw+y3w/X5fX+/Z8zNuCU2GIEiQTafaUssuxNw8Q
Hkh4pUYWTh2bYXuQjN4cO3bjzI7kGFQOUWXPKjtn9ipTsGxvic
HgbvvBlAAawyaBJv4CtTXU2oBuWDmsf396/hGL
      </map>
    </level>

    <level id="little-big-trouble" title="Little Big Trouble">
      <map>
eNpdi1EKwjAQRGebpMlON7WKiBfw/lfowYQ4AT/EhcdbmBkDrs
QrsvXILcIKwzKrXG1lhbAkiwRhrEUucmrC9cvF2fMEfDTwSXXq
RD2XXd7kzRjNPGi+U1ufaL9NnMHW7si8oRBYuh0Zti/vMQb+rq
+HK6vnNzt/OhmX8QHUWhGE
      </map>
    </level>

// ****************************************************************************

    <level id="widget" title="Widget">
      <unlock name="light-bulb" />
      <unlock name="music-player" />
      <map>
eNpdTVtOAzEMtMNuJp446UdRtsfgNlwAhPiG+5dpVSSEo5GVed
kNr59vH+/fX8fJXoBC2E507T6JSGEwW7ZLGA8YF8R3F4woTf6N
8NB/EBAoHcpZMAuYLCOZ2ZsNeJVXmVA/1MFbh7hw3ShxxGRvM7
thLmu8mLSuLteNIlT5q3JVN+rg8J3j/pQv+zR7OvvazJ+Laa6P
scec6wpp+M/ftb6mtPzl/+qbna4/z54jdA==
      </map>
    </level>

    <level id="light-bulb" title="Light Bulb">
      <unlock name="music-player" />
      <unlock name="game-system" />
      <map>
eNptycEOwjAMA1CnK6Ryk+ywruPA///mSA9IHLD0FMsR4NrxNt
nCpIeKUbGQKkvNvpTshda9mSX3pnQqgxp5I+joaePswcuCL8/f
KdQhtIG+n6DORQjIUWdDGY/xxJ/cP/luFfv9AdzSEdA=
      </map>
    </level>

    <level id="music-player" title="Music Player">
      <unlock name="game-system" />
      <unlock name="mp3-player" />
      <map>
eNp1jUsOw0AIQyFqhsHhkywy6QF6/yumzC6L1tITCGyZia6kj4
HdGCG8QWiiEC6UCobYhGDi3Xqxe5fmkBb1r6kBJ8BBGBK4euC9
B0bWfQAS5YvyHZPaR3Wck+oYCjuRlt5zq46NlWiJ9VBasqXQD9
2l55xqq1ZCmvxNPN1TL8r7Cyx8F7A=
      </map>
    </level>

    <level id="game-system" title="Game System">
      <unlock name="mp3-player" />
      <unlock name="boombox" />
      <map>
eNptyssKwzAMRNFRGio8emQRY2fR///NVIYuSumFsxgkAeaBlw
vSJTOQDIADwQmnwqhidImyttQWDoLTwMtBbSWWujWhU5pbcWnK
pDKoVjx4WNI9CWznYzwhfb+/wqeTI7F1644//X6vdhz3G1d0Ge
8=
      </map>
    </level>

    <level id="mp3-player" title="MP3 Player">
      <unlock name="boombox" />
      <unlock name="lime6pack" />
      <map>
eNp1jV0KwzAMg5X9NLbsLEkfkp5g979h58IeylgFH8JCRgnYVr
yzgtkPErMmOlMpjBuZOQWw8EBa0KMX7uEjsnkQnZHpQ6pbc0/y
KhAW6yxTWA10S+pJGRN0beIMhpoP2tDOjZ0DyglyTuU2SeD+XI
S4LXkR/NH+1TmjFMfN1IgL/X7VZY2NltvlxtkPPVD3D6bjIIQ=
      </map>
    </level>

    <level id="boombox" title="Boombox">
      <unlock name="lime6pack" />
      <unlock name="dvd-player" />
      <map>
eNptycsOwjAMRNGxQHUycR0eSYEd//+TZVggsailo+s4Bmwdb8
dCR6Hbl/YCMXpTm1pWSXqooU51yNTfMEZdS1CajGwx0IJWo4p5
rnD2mQJuNflg8tmSs4IvgoBdFj1ON7/63fe/wcEc3X+3M/r+AW
GeGrg=
      </map>
    </level>

    <level id="lime6pack" title="Lime 6-Pack">
      <unlock name="dvd-player" />
      <unlock name="tank" />
      <map>
eNq1iAsOwjAMxZwBjZb1w7Z0gvsftKQSHAFL1nuywNXwC+wl2H
vBCtVan2LZ65adLSNrlnCZW6tSTCW8EYppD31uNC8G8nz0lbSn
I53p1EN3HQHB+PL7/2532vgAKyJMsw==
      </map>
    </level>

    <level id="dvd-player" title="DVD Player">
      <unlock name="tank" />
      <unlock name="car" />
      <map>
eNq1y90KgzAMhuEv1VlNUzrzI+7+L9RlBwPZ+V54CCSEgMNx1g
lcJ0qWlAUqAupCtElJpKuU5NbE0UYYj8ifUK6eIn+duMMS+EXg
KOCTjI9iDJRni4Fll71rt26icv2E7B+7+/ykj1hBtuDW9z5jXG
9HNmID
      </map>
    </level>

    <level id="tank" title="Tank">
      <unlock name="car" />
      <map>
eNrFzEsOgzAMBNCxBASMIc3HBi7R+9+OTqWuuuymIz1NHCUW4L
jw3CKpx6xXLJoDmvF26olKK426oZHRpAmiSQgDm5DYBGUTNjah
U+GZcLA5Czu4wyn41im4y0XNsZrPtKwmo5qAVpp285RNbDepnB
v7VEAeLU5o6bW3XrxEjRbVm3fHJzeDr/zr7pf/A/L9Ahj6Mho=
      </map>
    </level>

    <level id="car" title="Car">
      <map>
eNqtjltuwzAMBJdAE8o0SfklS75H73+1dPMX9NdZYDDiQqAkQL
/wqzpMtZvaG55PuhHMpkJQafIAEdNCFzrooFd6pU/SxOo5COxc
YL3CImGX0k/OcBsIC6RFGXZNw7x09zZmn3pxCXNxkulPCVeZfC
GVJOeGWcF3hIB/lM673CGwijfDAFnnvsA33/LIw3ffY4s9j2je
ouXrX8Dc6T57fOSb3Z1dP6ivPzLbivc=
      </map>
    </level>

    </campaign>
  }
}
