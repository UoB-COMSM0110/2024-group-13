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
  private Action action;

  private boolean hovering;
  private float zoomRatio;

  public Button(String name, float w, float h, String text) {
    this(name, w, h, text, null);
  }

  public Button(String name, float w, float h, String text, Action action) {
    super(name, w, h, text);
    this.action = action;
    this.hovering = false;
    this.zoomRatio = 1.02;
  }

  Button setAction(Action action) { this.action = action; return this; }

  @Override
  public void onMouseEvent(MouseEvent e) {
    if (e instanceof MouseClickedEvent) {
      MouseClickedEvent click = (MouseClickedEvent)e;
      if (click.getButton() == LEFT && isMouseEventRelated(click)) {
        onClickedOn();
      }
    } else if (e instanceof MouseMovedEvent) {
      MouseMovedEvent mouse = (MouseMovedEvent)e;
      if (isMouseEventRelated(mouse)) {
        onHoverOn();
      } else {
        onHoverOff();
      }
    }
  }

  public void onClickedOn() {
    if (this.action != null) { this.action.run(); }
  }

  public void onHoverOn() {
    if (!this.hovering) {
      this.hovering = true;
      zoom(this.zoomRatio);
    }
  }

  public void onHoverOff() {
    if (this.hovering) {
      this.hovering = false;
      zoom(1.0 / this.zoomRatio);
    }
  }

  public void zoom(float ratio) {
      float centerX = getCenterX();
      float centerY = getCenterY();
      float newW = getW() * ratio;
      float newH = getH() * ratio;
      setW(newW).setH(newH).setCenterX(centerX).setCenterY(centerY);
  }
}
