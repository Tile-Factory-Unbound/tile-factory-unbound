package lib
{
  public class Util
  {
    public static function rand(max : int) : int
    {
      return Math.floor(Math.random() * max);
    }

    public static function shuffle(list : Array) : void
    {
      var j = list.length - 1;
      while (j > 0)
      {
        var k = rand(j+1);
        var temp : * = list[j];
        list[j] = list[k];
        list[k] = temp;
        --j;
      }
    }

    public static function makeChange(func : Function, ...boundArgs) : Function
    {
      return function(...dynamicArgs) : *
      {
        return func.apply(null, boundArgs.concat(dynamicArgs))
      }
    }
  }
}
