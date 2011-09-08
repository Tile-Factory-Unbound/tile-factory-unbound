package ui
{
  import flash.filters.GlowFilter;

  import lib.Point;

  import lib.ui.Image;
  import lib.ui.ImageList;
  import lib.ui.ImageType;

  import logic.Item;
  import logic.Map;
  import logic.Part;
  import logic.PartSpec;

  public class PartView
  {
    public function PartView(spec : PartSpec,
                             newImages : lib.ui.ImageList,
                             newAnims : AnimList) : void
    {
      type = spec.type;
      images = newImages;
      anims = newAnims;
      updateDir(spec.dir);
      updatePos(spec.pos);
      partAnim = null;
      cloud = null;
      cloudAnim = null;
      if (partFrames[type] != null)
      {
        partAnim = partFrames[type].clone();
        partAnim.image = part;
        if (type == Part.CONVEYER)
        {
          partAnim.cycle = true;
        }
        anims.add(partAnim);
      }
      updatePower(spec.power);
      updateLocked(spec.locked);
    }

    public function cleanup() : void
    {
      images.remove(part);
      part.cleanup();
      if (partAnim != null)
      {
        anims.remove(partAnim);
      }
      if (cloud != null)
      {
        images.remove(cloud);
        cloud.cleanup();
      }
      if (cloudAnim != null)
      {
        anims.remove(cloudAnim);
      }
    }

    public function show() : void
    {
      part.setVisible(true);
    }

    public function hide() : void
    {
      part.setVisible(false);
    }

    public function updateDir(newDir : Dir) : void
    {
      lastDir = newDir;
      if (! shouldRotate(type) && part != null)
      {
        cleanup();
        part = null;
      }
      if (part == null)
      {
        part = new lib.ui.Image(makeType(newDir));
        images.add(part);
        if (partAnim != null)
        {
          partAnim.image = part;
        }
      }
      if (shouldRotate(type))
      {
        part.setRotation(newDir.toAngle());
      }
    }

    public function updatePos(newPos : Point) : void
    {
      lastPos = newPos.clone();
      part.setPos(Map.toCenterPixel(newPos));
    }

    public function updatePower(power : Boolean) : void
    {
      if (shouldGlow(type))
      {
        if (power)
        {
          part.setFilter(glow);
        }
        else
        {
          part.setFilter(null);
        }
      }
      else
      {
        if (power)
        {
          part.setFrame(2);
          if (type == Part.CONVEYER)
          {
            animate(null);
          }
        }
        else
        {
          part.setFrame(1);
        }
        if (partAnim != null)
        {
          partAnim.paused = true;
        }
      }
    }

    public function updateLocked(locked : Boolean) : void
    {
      if (locked)
      {
        part.setFilter(lockGlow);
      }
      else
      {
        part.setFilter(null);
      }
    }

    public function animate(source : Item) : void
    {
      if (partAnim != null)
      {
        partAnim.play();
      }
      if (type == Part.SPRAYER)
      {
        if (cloud == null)
        {
          var imageType = new ImageType(getCloudLinkage(source),
                                        ImageConfig.cloudLayer,
                                        new Point(40, 40));
          cloud = new Image(imageType);
          images.add(cloud);
          var pos = Map.toCenterPixel(Dir.step(lastPos, lastDir));
          cloud.setPos(pos);
          cloud.setRotation(lastDir.toAngle());
          cloudAnim = new Anim(1, 16);
          cloudAnim.image = cloud;
          anims.add(cloudAnim);
        }
        cloudAnim.play();
      }
    }

    function getCloudLinkage(source : Item) : String
    {
      var result = "Cloud_Paint_15";
      if (source != null)
      {
        var itemType = source.getType();
        if (itemType == Item.SOLVENT)
        {
          result = "Cloud_Solvent";
        }
        else if (itemType == Item.GLUE)
        {
          result = "Cloud_Glue";
        }
        else if (itemType >= Item.STENCIL_BEGIN && itemType < Item.STENCIL_END)
        {
          result = "Cloud_Stencil";
        }
        else if (itemType >= Item.PAINT_BEGIN && itemType < Item.PAINT_END)
        {
          result = "Cloud_Paint_" + String(itemType - Item.PAINT_BEGIN);
        }
      }
      return result;
    }

    public function getTrackSprite() : TrackView
    {
      return new TrackView(images, anims);
    }

    function makeType(dir : Dir) : ImageType
    {
      var layer = ImageConfig.floorLayer;
//      if (Part.isBarrierType(type))
//      {
//        layer = ImageConfig.barrierLayer;
//      }
      return new ImageType(getLinkage(type, dir),
                           layer,
                           new Point(Map.tileSize, Map.tileSize));
    }

    var type : int;
    var images : lib.ui.ImageList;
    var part : lib.ui.Image;
    var partAnim : Anim;
    var cloud : lib.ui.Image;
    var cloudAnim : Anim;
    var anims : AnimList;
    var lastPos : Point;
    var lastDir : Dir;

    public static function shouldRotate(type : int) : Boolean
    {
      return partLinkage[type].length <= 1;
    }

    public static function getLinkage(type : int, dir : Dir) : String
    {
      var list = partLinkage[type];
      if (list.length == 0)
      {
        return "TileMakerClip";
      }
      else if (list.length == 1)
      {
        return list[0];
      }
      else
      {
        return list[dir.toIndex()];
      }
    }

    static var partLinkage = [["AllClip"], ["SomeClip"], ["NoneClip"],
                              ["MemClip"], ["SetClip"], ["ClearClip"],
                              ["ConveyerClip"], ["BarrierClip"],
                              ["RotaterClip", "CounterClip",
                               "RotaterClip", "CounterClip"],
                              ["FlipVertClip", "FlipVertClip",
                               "FlipClip", "FlipClip"],
                              ["InvertClip"], ["SensorClip"],
                              ["SprayerClip"], ["MixerClip"],
                              ["CopierClip"],
                              ["TileClip"], ["SolventClip"], ["GlueClip"],
//                              ["TriangleMakerClip"], ["RectangleMakerClip"],
//                              ["SmallCircleMakerClip"], ["CircleMakerClip"],
//                              ["BigCircleMakerClip"],
                              ["StencilBackground"], ["StencilBackground"],
                              ["StencilBackground"], ["StencilBackground"],
                              ["StencilBackground"],
                              ["WhiteClip"], ["CyanClip"], ["MagentaClip"],
                              ["YellowClip"], ["BlackClip"]];

    static var partFrames = [null, null, null, null, null, null,
                             new Anim(2, 17), null, new Anim(2, 17),
                             new Anim(2, 17), new Anim(2, 17),
                             null, new Anim(2, 17), new Anim(2, 17),
                             new Anim(2, 17),

                             null, null, null,
                             null, null, null, null, null,
                             null, null, null, null, null];

    public static function shouldGlow(type : int) : Boolean
    {
      return false;
    }

    public static var glow = new GlowFilter(0xffff00, 0.8, 10, 10, 3, 3, true);
    public static var lockGlow = new GlowFilter(0x0000ff, 0.8, 10, 10, 3, 3, true);
  }
}
