package lib
{
  public class DNode
  {
    public function DNode() : void
    {
      this.next = null;
      this.prev = null;
      this.data = null;
    }

    public var next : DNode;
    public var prev : DNode;
    public var data : *;
  }
}
