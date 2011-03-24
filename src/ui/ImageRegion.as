package ui
{
  import flash.display.Shape;

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
      super(newType);
    }

    public function setRegion(newRegion : RegionList) : void
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
      else if (! RegionList.isEqual(region, newRegion))
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
        regionClip.graphics.clear();
        if (region != null)
        {
          region.drawRegions(regionClip.graphics, -(Map.tileSize - 2)/2,
                             Map.tileSize - 2)
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
        image.addChild(regionClip);
      }
    }

    override protected function resetImage(window : Window) : void
    {
      super.resetImage(window);
      regionClip = new Shape();
      image.addChild(regionClip);
      regionClip.cacheAsBitmap = true;
    }

    override protected function clearImage() : void
    {
      if (regionClip != null)
      {
        regionClip.parent.removeChild(regionClip);
      }
      regionClip = null;
      super.clearImage();
    }

    override protected function invalidate() : void
    {
      super.invalidate();
      regionChanged = true;
    }

    var region : RegionList;
    var regionChanged : Boolean;
    var regionClip : Shape;
  }
}
