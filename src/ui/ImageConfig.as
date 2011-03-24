package ui
{
  import lib.Point;
  import lib.ui.ImageType;
  import logic.Map;

  public class ImageConfig
  {
    public static var goalLayer : int = 0;
    public static var goalTileLayer : int = 1;
    public static var goalTextLayer : int = 2;
    public static var trackLayer : int = 3;
    public static var floorLayer : int = 4;
    public static var wireLayer : int = 5;
    public static var itemLayer : int = 6;
    public static var cloudLayer : int = 7;
    public static var goalTop : int = 8;
    public static var goalTileTop : int = 9;
    public static var goalTextTop : int = 10;
    public static var layerCount : int = 11;

    public static var item = new lib.ui.ImageType("ItemClip", itemLayer,
                                                  new lib.Point(Map.tileSize,
                                                                Map.tileSize));
    public static var goalTile
      = new lib.ui.ImageType("ItemClip", goalTileLayer,
                             new lib.Point(Map.tileSize,
                                           Map.tileSize));
    public static var goalText = new lib.ui.ImageType("EmptyClip",
                                                      goalTextLayer,
                                                      new lib.Point(44, 89));
    public static var track = new lib.ui.ImageType("TrackClip", trackLayer,
                                                   new lib.Point(Map.tileSize,
                                                                 Map.tileSize));
    public static var explosion
      = new lib.ui.ImageType("ExplosionClip", cloudLayer,
                             new lib.Point(Map.tileSize,
                                           Map.tileSize));
  }
}
