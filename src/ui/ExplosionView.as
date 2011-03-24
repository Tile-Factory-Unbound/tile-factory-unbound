package ui
{
  import lib.Point;
  import lib.ui.Image;
  import lib.ui.ImageList;

  public class ExplosionView
  {
    public function ExplosionView(pos : Point,
                                  newImages : ImageList,
                                  newAnims : AnimList) : void
    {
      images = newImages;
      anims = newAnims;
      explosion = new Image(ImageConfig.explosion);
      explosion.setPos(pos);
      images.add(explosion);
      animation = new Anim(1, 26);
      animation.image = explosion;
      animation.play();
      anims.add(animation);
    }

    public function cleanup() : void
    {
      images.remove(explosion);
      explosion.cleanup();
      anims.remove(animation);
    }

    public function isDone() : Boolean
    {
      return animation.frame >= 25;
    }

    var images : ImageList;
    var anims : AnimList;
    var explosion : Image;
    var animation : Anim;
  }
}
