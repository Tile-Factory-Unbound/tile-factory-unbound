package lib.ui
{
  import flash.display.MovieClip;
  import flash.filters.BitmapFilter;
  import flash.utils.getDefinitionByName;

  import lib.Point;

  public class Image
  {
    public static function createClip(linkage : String) : MovieClip
    {
      var className : * = getDefinitionByName(linkage) as Class;
      return new className();
    }

    public function Image(newType : ImageType) : void
    {
      image = null;
      type = newType;
      pos = new lib.Point(0, 0);
      visible = true;
      frame = 1;
      filter = null;
      rotation = 0;
      alpha = 1.0;
      scale = 1.0;

      invalidate();
    }

    public function cleanup() : void
    {
      clearImage();
    }

    public function setType(newType : ImageType) : void
    {
      if (type != newType)
      {
        type = newType;
        typeChanged = true;
      }
    }

    public function setPos(newPos : lib.Point) : void
    {
      if (! lib.Point.isEqual(pos, newPos))
      {
        pos = newPos.clone();
        posChanged = true;
      }
    }

    public function setVisible(newVisible : Boolean) : void
    {
      if (visible != newVisible)
      {
        visible = newVisible;
        visibleChanged = true;
      }
    }

    public function setFrame(newFrame : int) : void
    {
      if (frame != newFrame)
      {
        frame = newFrame;
        frameChanged = true;
      }
    }

    public function setFilter(newFilter : flash.filters.BitmapFilter) : void
    {
      if (filter != newFilter)
      {
        filter = newFilter;
        filterChanged = true;
      }
    }

    public function setRotation(newRotation : int) : void
    {
      if (rotation != newRotation)
      {
        rotation = newRotation;
        rotationChanged = true;
      }
    }

    public function setAlpha(newAlpha : Number) : void
    {
      if (alpha != newAlpha)
      {
        alpha = newAlpha;
        alphaChanged = true;
      }
    }

    public function setScale(newScale : Number) : void
    {
      if (Math.abs(scale - newScale) > 0.01)
      {
        scale = newScale;
        scaleChanged = true;
      }
    }

    public function update(window : Window) : void
    {
      if (window.isMoved())
      {
        posChanged = true;
      }
      if (posChanged || visibleChanged)
      {
        if (isInside(window) && visible)
        {
          if (image == null)
          {
            resetImage(window);
          }
        }
        else
        {
          clearImage();
        }
        visibleChanged = false;
      }
      updateType(window);
      updatePos(window);
      updateFrame();
      updateFilter();
      updateRotation();
      updateAlpha();
      updateScale();
    }

    function updateType(window : Window) : void
    {
      if (typeChanged && image != null)
      {
        resetImage(window);
      }
      typeChanged = false;
    }

    function updatePos(window : Window) : void
    {
      if (posChanged && image != null)
      {
        image.x = pos.x - window.getOffset().x;
        image.y = pos.y - window.getOffset().y;
      }
      posChanged = false;
    }

    protected function updateFrame() : void
    {
      if (frameChanged && image != null)
      {
        image.gotoAndStop(frame);
      }
      frameChanged = false;
    }

    function updateFilter() : void
    {
      if (filterChanged && image != null)
      {
        if (filter == null)
        {
          image.filters = null;
        }
        else
        {
          image.filters = [filter];
        }
      }
      filterChanged = false;
    }

    function updateRotation() : void
    {
      if (rotationChanged && image != null)
      {
        image.rotation = rotation;
      }
      rotationChanged = false;
    }

    function updateAlpha() : void
    {
      if (alphaChanged && image != null)
      {
        image.alpha = alpha;
      }
      alphaChanged = false;
    }

    function updateScale() : void
    {
      if (scaleChanged && image != null)
      {
        image.scaleX = scale;
        image.scaleY = scale;
      }
      scaleChanged = false;
    }

    function isInside(window : Window) : Boolean
    {
      return (pos.x >= window.getOffset().x - type.size.x)
        && (pos.x <= window.getOffset().x + window.getSize().x + type.size.x)
        && (pos.y >= window.getOffset().y - type.size.y)
        && (pos.y <= window.getOffset().y + window.getSize().y + type.size.y);
    }

    protected function resetImage(window : Window) : void
    {
      clearImage();
      image = createClip(type.linkage);
      var parent = window.getLayer(type.layer);
      parent.addChild(image);
      image.cacheAsBitmap = true;
      invalidate();
      typeChanged = false;
    }

    protected function clearImage() : void
    {
      if (image != null)
      {
        image.parent.removeChild(image);
      }
      image = null;
    }

    protected function invalidate() : void
    {
      typeChanged = true;
      posChanged = true;
      visibleChanged = true;
      frameChanged = true;
      filterChanged = true;
      rotationChanged = true;
      alphaChanged = true;
      scaleChanged = true;
    }

    protected var image : MovieClip;

    var type : ImageType;
    var typeChanged : Boolean;

    var pos : lib.Point;
    var posChanged : Boolean;

    var visible : Boolean;
    var visibleChanged : Boolean;

    protected var frame : int;
    protected var frameChanged : Boolean;

    var filter : flash.filters.BitmapFilter;
    var filterChanged : Boolean;

    var rotation : int;
    var rotationChanged : Boolean;

    var alpha : Number;
    var alphaChanged : Boolean;

    var scale : Number;
    var scaleChanged : Boolean;
  }
}
