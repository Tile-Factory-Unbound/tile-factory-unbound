package logic.change
{
  import lib.Point;
  import lib.Util;

  import logic.Item;
  import logic.Map;
  import logic.Model;

  import ui.ExplosionView;
  import ui.Sound;
  import ui.View;

  public class ChangeWorld
  {
    public static function togglePlay(model : Model, view : View) : void
    {
      if (model.isPlaying())
      {
        model.stopPlay();
        view.stopPlay();
      }
      else
      {
        model.startPlay();
        view.startPlay();
      }
    }

    public static function pausePlay(model : Model, view : View) : void
    {
      model.pause();
    }

    public static function resumePlay(model : Model, view : View) : void
    {
      model.resume();
    }

    public static function slowPlay(model : Model, view : View) : void
    {
      model.setSlow();
    }

    public static function fastPlay(model : Model, view : View) : void
    {
      model.setFast();
    }

    public static function turboPlay(model : Model, view : View) : void
    {
      model.setTurbo();
    }

    public static function stepPlay(model : Model, view : View) : void
    {
      model.beginStepping();
    }

    public static function itemBlocked(type : int, pos : Point,
                                       model : Model, view : View) : void
    {
      if (model.getMap().insideMap(pos))
      {
        destroyGroup(model.getMap().getTile(pos).item, model, view);
        destroyGroup(model.getMap().getTile(pos).itemNext, model, view);
      }
//      trace("item blocked: " + type);
//      model.stopPlay();
//      view.stopPlay();
    }

    static function destroyGroup(item : Item,
                                 model : Model, view : View) : void
    {
      if (item != null)
      {
        var group = item.getGroup();
        var members = group.getMembers();
        for each (var current in members)
        {
          model.getChanges().add(Util.makeChange(addExplosion,
                                               current.getPixelPos().clone()));
          model.getChanges().add(Util.makeChange(ChangeItem.destroy, current));
          model.smash();
        }
      }
    }

    static function addExplosion(pos : Point,
                                 model : Model, view : View) : void
    {
      var explosion = new ExplosionView(pos, view.getImages(),
                                        view.getAnims());
      view.addExplosion(explosion);
      Sound.play(Sound.JAM);
    }
  }
}
