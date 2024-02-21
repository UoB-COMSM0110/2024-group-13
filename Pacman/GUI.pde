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
  void onEvents(GameInfo gInfo, ArrayList<Event> events) {
    for (Event e : events) {
      if (!(e instanceof MouseEvent) || !isMouseEventRelative((MouseEvent)e)) {
        continue;
      }
      if (e instanceof MouseClickedEvent) {
        onMouseClickedEvent(gInfo);
      }
    }
  }

  private boolean isMouseEventRelative(MouseEvent e) {
    return getX() < e.getX() && e.getX() < getX() + getW()
      && getY() < e.getY() && e.getY() < getY() + getH();
  }

  void onMouseClickedEvent(GameInfo gInfo) {
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
