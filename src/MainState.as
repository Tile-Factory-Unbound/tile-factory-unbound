// MainState.as
//
// The root for the shallow hierarchy used to switch between the main
// pre-game menus and the game itself. Each menu and the game only
// exist for the time in which the player interacts with it.

package
{
  public interface MainState
  {
    function cleanup() : void;
    function resize() : void;
  }
}
