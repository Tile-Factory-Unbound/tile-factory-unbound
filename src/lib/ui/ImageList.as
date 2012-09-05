package lib.ui
{
  import lib.DList;
  import lib.DIterator;

  public class ImageList
  {
    public function ImageList() : void
    {
      images = new lib.DList();
    }

    public function cleanup() : void
    {
      var pos : DIterator = images.frontIterator();
      for (; pos.isValid(); pos.increment())
      {
        pos.get().cleanup();
      }
    }

    public function add(newImage : Image) : void
    {
      images.pushBack(newImage);
    }

    public function remove(oldImage : Image) : void
    {
      images.remove(oldImage);
    }

    public function update(window : Window) : void
    {
      var pos : DIterator = images.frontIterator();
      for (; pos.isValid(); pos.increment())
      {
        pos.get().update(window);
      }
      window.clearMoved();
    }

    var images : DList;
  }
}
