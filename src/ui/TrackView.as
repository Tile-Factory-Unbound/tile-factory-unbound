package ui
{
  import lib.Point;
  import lib.ui.Image;
  import lib.ui.ImageList;
  import logic.Map;

  public class TrackView
  {
    public function TrackView(newImages : ImageList,
                              newAnims : AnimList) : void
    {
      images = newImages;
      anims = newAnims;
      track = null;
      trackAnim = null;
    }

    public function destroy() : void
    {
      if (track != null)
      {
        images.remove(track);
        anims.remove(trackAnim);
        track.cleanup();
        track = null;
      }
    }

    public function update(pos : Point, dir : Dir,
                           shouldAnimate : Boolean) : void
    {
      if (track == null)
      {
        track = new lib.ui.Image(ImageConfig.track);
        images.add(track);
        trackAnim = new Anim(2, 17);
        trackAnim.image = track;
        trackAnim.cycle = true;
        anims.add(trackAnim);
      }
      track.setPos(Map.toCenterPixel(pos));
      if (dir == null)
      {
        trackAnim.paused = true;
        track.setFrame(1);
      }
      else
      {
        track.setRotation(dir.toAngle());
        if (shouldAnimate)
        {
          trackAnim.frame = 2;
          trackAnim.paused = false;
        }
        else
        {
          trackAnim.paused = true;
          track.setFrame(2);
        }
      }
    }

    var images : lib.ui.ImageList;
    var anims : AnimList;
    var track : lib.ui.Image;
    var trackAnim : Anim;
  }
}
