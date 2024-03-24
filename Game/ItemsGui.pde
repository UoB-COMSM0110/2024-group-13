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
  private String prefix;
  private String text;
  private int textColor;
  private int textSize;
  private PFont textFont;
  private int textAlignHorizon;
  private int textAlignVertical;

  public Label(String name, float w, float h, String text) {
    super(name, w, h);
    this.prefix = "";
    this.text = text;
    this.textColor = color(100, 20, 20);
    this.textSize = fontSizeMinecraft;
    this.textFont = fontMinecraft;
    this.textAlignHorizon = CENTER;
    this.textAlignVertical = CENTER;
  }

  public Label setPrefix(String prefix) { this.prefix = prefix; return this; }
  public Label setText(String text) { this.text = text; return this; }

  public Label setTextAlignHorizon(int align) { this.textAlignHorizon = align; return this; }

  @Override
  public void draw() {
    super.draw();
    drawTextContent();
  }

  private void drawTextContent() {
    float alignPointX = getX();
    float alignPointY = getY();
    switch (this.textAlignHorizon) {
      case LEFT: { alignPointX = getLeftX(); break; }
      case CENTER: { alignPointX = getCenterX(); break; }
      case RIGHT: { alignPointX = getRightX(); break; }
    }
    switch (this.textAlignVertical) {
      case TOP: { alignPointY = getTopY(); break; }
      case CENTER: { alignPointY = getCenterY(); break; }
      case BOTTOM: { alignPointY = getBottomY(); break; }
    }
    fill(this.textColor);
    textFont(this.textFont, this.textSize);
    textAlign(this.textAlignHorizon, this.textAlignVertical);
    text(this.prefix + this.text, alignPointX, alignPointY);
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

  @Override
  public PImage getImage() {
    return imageButton;
  }
}
