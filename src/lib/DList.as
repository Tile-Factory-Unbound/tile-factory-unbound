// DList.as
//
// A custom doubly-linked list implementation.

package lib
{
  public class DList
  {
    public function DList() : void
    {
      head = null;
      tail = null;
      currentSize = 0;
    }

    public function size() : int
    {
      return currentSize;
    }

    public function isEmpty() : Boolean
    {
      return head == null;
    }

    public function frontIterator() : DIterator
    {
      var result : DIterator = new DIterator();
      result.setNode(head);
      return result;
    }

    public function backIterator() : DIterator
    {
      var result : DIterator = new DIterator();
      result.setNode(tail);
      return result;
    }

    public function insert(pos : DIterator,newData : *) : DIterator
    {
      var result : DIterator = new DIterator();
      if(!pos.isValid())
      {
        pushBack(newData);
        result.setNode(tail);
      }
      else if(pos.getNode() == head)
      {
        pushFront(newData);
        result.setNode(head);
      }
      else
      {
        var newNode : DNode = new DNode();
        newNode.data = newData;
        newNode.prev = pos.getNode().prev;
        newNode.next = pos.getNode();
        pos.getNode().prev.next = newNode;
        pos.getNode().prev = newNode;
        result.setNode(newNode);
        ++currentSize;
      }
      return result;
    }

    public function erase(pos : DIterator) : DIterator
    {
      var result : DIterator = new DIterator();
      if(pos.isValid())
      {
        if(pos.getNode() == head)
        {
          popFront();
          result.setNode(head);
        }
        else if(pos.getNode() == tail)
        {
          popBack();
          result.setNode(tail);
        }
        else
        {
          pos.getNode().prev.next = pos.getNode().next;
          pos.getNode().next.prev = pos.getNode().prev;
          result.setNode(pos.getNode().next);
          --currentSize;
        }
      }
      return result;
    }

    public function remove(value : *) : void
    {
      var pos = find(value);
      if (pos.isValid())
      {
        erase(pos);
      }
    }

    public function clear() : void
    {
      head = null;
      tail = null;
      currentSize = 0;
    }

    // Returns an iterator pointing to value or an invalid iterator
    public function find(value : *) : DIterator
    {
      var current = frontIterator();
      for (; current.isValid(); current.increment())
      {
        if (current.get() == value)
        {
          break;
        }
      }
      return current;
    }

    public function front() : *
    {
      if(head != null)
      {
        return head.data;
      }
      else
      {
        return null;
      }
    }

    public function back() : *
    {
      if(tail != null)
      {
        return tail.data;
      }
      else
      {
        return null;
      }
    }

    public function pushFront(newData : *) : void
    {
      var newNode : DNode = new DNode();
      newNode.data = newData;
      if(head == null)
      {
        head = newNode;
        tail = newNode;
      }
      else
      {
        head.prev = newNode;
        newNode.next = head;
        head = newNode;
      }
      ++currentSize;
    }

    public function pushBack(newData : *) : void
    {
      var newNode : DNode = new DNode();
      newNode.data = newData;
      if(tail == null)
      {
        head = newNode;
        tail = newNode;
      }
      else
      {
        tail.next = newNode;
        newNode.prev = tail;
        tail = newNode;
      }
      ++currentSize;
    }

    public function popFront() : void
    {
      if (head != null && tail != null)
      {
        if(head == tail)
        {
          head = null;
          tail = null;
        }
        else
        {
          head.next.prev = null;
          head = head.next;
        }
        --currentSize;
      }
    }

    public function popBack() : void
    {
      if (head != null && tail != null)
      {
        if(head == tail)
        {
          head = null;
          tail = null;
        }
        else
        {
          tail.prev.next = null;
          tail = tail.prev;
        }
        --currentSize;
      }
    }

    protected var head : DNode;
    protected var tail : DNode;
    protected var currentSize : int;
  }
}
