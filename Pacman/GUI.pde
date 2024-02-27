String buttonImagePath = "GUI/ButtonImage.jpeg";
PImage buttonImage;
  
public class Button extends LocalItem {
  String text;
  int textColor;
  int textSize;
  PFont textFont;
  
  public Button(String name, float x, float y, String text) {
    super(name, x, y);
    this.text = text;
    this.textColor = color(100, 20, 20);
    this.textSize = 20;
    this.textFont = createFont("Arial-Bold", this.textSize);
  }

  @Override
  void onMouseEvent(GameInfo gInfo, MouseEvent e) {
    if (!isMouseEventRelative(e)) {
      return;
    }
    if (e instanceof MouseClickedEvent) {
      onMouseClickedEvent(gInfo, (MouseClickedEvent)e);
    }
  }

  // Whether the mouse cursor is over the button when the event happened.
  private boolean isMouseEventRelative(MouseEvent e) {
    return getX() < e.getX() && e.getX() < getX() + getW()
      && getY() < e.getY() && e.getY() < getY() + getH();
  }

  // Called when mouse clicks on the button.
  void onMouseClickedEvent(GameInfo gInfo, MouseClickedEvent e) {
    if (text != "Hello") {
      text = "Hello";
    } else {
      text = "World";
    }
  }

  @Override
  public PImage getImage() {
    if (buttonImage == null) { buttonImage = loadImage(buttonImagePath); }
    return buttonImage;
  }

  @Override
  public void draw(GameInfo gInfo) {
    super.draw(gInfo);
    fill(this.textColor);
    textSize(this.textSize);
    textFont(this.textFont);
    textAlign(CENTER, CENTER);
    text(this.text, getX() + getW() / 2, getY() + getH() / 2);
  }
}
