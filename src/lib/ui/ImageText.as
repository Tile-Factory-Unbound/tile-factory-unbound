package lib.ui
{
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import ui.TextClip;

  public class ImageText extends Image
  {
    public function ImageText(newType : ImageType) : void
    {
      text = null;
      textClip = null;
      super(newType);
    }

    public function setText(newText : String) : void
    {
      if (text != newText)
      {
        text = newText;
        textChanged = true;
      }
    }

    override public function update(window : Window) : void
    {
      super.update(window);
      updateText();
    }

    function updateText() : void
    {
      if (textChanged && image != null && textClip != null)
      {
        if (text == null)
        {
          textClip.visible = false;
        }
        else
        {
          textClip.text.text = text;
          textClip.visible = true;
          textClip.text.x = - textClip.text.width / 2;
          textClip.text.y = - textClip.text.height / 2;
        }
      }
      textChanged = false;
    }

    override protected function updateFrame() : void
    {
      if (frameChanged && image != null && textClip != null)
      {
        super.updateFrame();
        textClip.parent.removeChild(textClip);
        image.addChild(textClip);
      }
    }

    override protected function resetImage(window : Window) : void
    {
      super.resetImage(window);
      textClip = new ui.TextClip();
      image.addChild(textClip);
      textClip.cacheAsBitmap = true;
      textClip.text.autoSize = TextFieldAutoSize.CENTER;
    }

    override protected function clearImage() : void
    {
      if (textClip != null)
      {
        textClip.parent.removeChild(textClip);
      }
      textClip = null;
      super.clearImage();
    }

    override protected function invalidate() : void
    {
      super.invalidate();
      textChanged = true;
    }

    var textClip : ui.TextClip;
    var text : String;
    var textChanged : Boolean;
  }
}
