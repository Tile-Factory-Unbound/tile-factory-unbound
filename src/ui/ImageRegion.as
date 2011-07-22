package ui
{
  import flash.display.Bitmap;
  import flash.display.BitmapData;

  import lib.ui.Image;
  import lib.ui.ImageType;
  import lib.ui.Window;

  import logic.Map;

  public class ImageRegion extends Image
  {
    public function ImageRegion(newType : ImageType) : void
    {
      region = null;
      regionClip = null;
      data = null;
      super(newType);
    }

    public function setRegion(newRegion : TilePixel) : void
    {
      if (region == null && newRegion != null)
      {
        region = newRegion.clone();
        regionChanged = true;
      }
      else if (newRegion == null)
      {
        region = null;
        regionChanged = true;
      }
      else if (! TilePixel.isEqual(region, newRegion))
      {
        region.copyFrom(newRegion);
        regionChanged = true;
      }
    }

    override public function update(window : Window) : void
    {
      super.update(window);
      updateRegion();
    }

    function updateRegion() : void
    {
      if (regionChanged && image != null && regionClip != null)
      {
        if (region != null)
        {
          region.drawRegions(regionClip.bitmapData);
        }
      }
      regionChanged = false;
    }

    override protected function updateFrame() : void
    {
      if (frameChanged && image != null && regionClip != null)
      {
        super.updateFrame();
        regionClip.parent.removeChild(regionClip);
        if (frame == 1)
        {
          image.addChild(regionClip);
        }
      }
    }

    override protected function resetImage(window : Window) : void
    {
      super.resetImage(window);
      data = new BitmapData(TileBit.dim, TileBit.dim, false);
      regionClip = new Bitmap(data);
      regionClip.x = -(TileBit.dim/2);
      regionClip.y = -(TileBit.dim/2);
      image.addChild(regionClip);
    }

    override protected function clearImage() : void
    {
      if (regionClip != null)
      {
        if (regionClip.parent != null)
        {
          regionClip.parent.removeChild(regionClip);
        }
        data.dispose();
      }
      regionClip = null;
      data = null;
      super.clearImage();
    }

    override protected function invalidate() : void
    {
      super.invalidate();
      regionChanged = true;
    }

    var region : TilePixel;
    var regionChanged : Boolean;
    var regionClip : Bitmap;
    var data : BitmapData;
  }
}
