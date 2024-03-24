final String imagePathButton = "data/Button.png";
PImage imageButton;
final String fontPathMinecraft = "data/Minecraft.ttf";
final int fontSizeMinecraft = 20;
PFont fontMinecraft;

void loadResourcesForGui() {
  imageButton = loadImage(imagePathButton);
  fontMinecraft = createFont(fontPathMinecraft, fontSizeMinecraft, true);
}

  
public class Label extends LocalItem {
  String text;
  int textColor;
  int textSize;
  PFont textFont;

  public Label(String name, float w, float h, String text) {
    super(name, w, h);
    this.text = text;
    this.textColor = color(100, 20, 20);
    this.textSize = fontSizeMinecraft;
    this.textFont = fontMinecraft;
  }

  @Override
  public PImage getImage() {
    return imageButton;
  }

  @Override
  public void draw() {
    super.draw();
    fill(this.textColor);
    textFont(this.textFont, this.textSize);
    textAlign(CENTER, CENTER);
    text(this.text, getCenterX(), getCenterY());
  }
}


public class Button extends Label {
  public Button(String name, float w, float h, String text) {
    super(name, w, h, text);
  }

  @Override
  void onMouseEvent(MouseEvent e) {
    if (!isMouseEventRelative(e)) {
      return;
    }
    if (e instanceof MouseClickedEvent) {
      onMouseClickedEvent((MouseClickedEvent)e);
    }
  }

  // Whether the mouse cursor is over the button when the event happened.
  private boolean isMouseEventRelative(MouseEvent e) {
    return getX() < e.getX() && e.getX() < getX() + getW()
      && getY() < e.getY() && e.getY() < getY() + getH();
  }

  // Called when mouse clicks on the button.
  void onMouseClickedEvent(MouseClickedEvent e) {
    if(text == "Play"){
      page = new PlayPage(page);
    }
    else if (text == "Help"){
      page = new HelpPage(page);
    }
    else if(text == "Back"){
      page  = page.previousPage;
    }
    else if(text == "Start"){
      page = new PlayPage(page);
    }
  }
}
