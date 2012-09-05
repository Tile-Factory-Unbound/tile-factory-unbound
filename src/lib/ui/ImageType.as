package lib.ui
{
  import lib.Point;

  public class ImageType
  {
    public function ImageType(newLinkage : String, newLayer : int,
                              newSize : lib.Point) : void
    {
      linkage = newLinkage;
      layer = newLayer;
      size = newSize.clone();
    }

    public var linkage : String;
    public var layer : int;
    public var size : lib.Point;
  }
}
