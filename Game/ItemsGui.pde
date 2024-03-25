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
    this.textAlignHorizon = LEFT;
    this.textAlignVertical = CENTER;
  }

  public Label setPrefix(String prefix) { this.prefix = prefix; return this; }
  public Label setText(String text) { this.text = text; return this; }
  public Label setTextAlignHorizon(int align) { this.textAlignHorizon = align; return this; }

  public String getText() { return this.text; }

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
    setTextAlignHorizon(CENTER);
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

  @Override
  public PImage getImage() {
    return imageButton;
  }
}


@FunctionalInterface
public static interface InputBoxCallback {
  void onTextChange(InputBox inputBox);
}

public class InputBox extends Label {
  private String defaultText;
  private int maxLen;
  private InputBoxCallback callback;

  private boolean onFocus;
  private String prevText;

  public InputBox(String name, float w, float h, int maxLen) {
    this(name, w, h, maxLen, null);
  }

  public InputBox(String name, float w, float h, int maxLen, InputBoxCallback callback) {
    super(name, w, h, "");
    this.defaultText = "";
    this.maxLen = maxLen;
    this.callback = callback;
    this.onFocus = false;
    this.prevText = "";
  }

  @Override
  public InputBox setText(String text) {
    this.prevText = getText();
    super.setText(text);
    if (!text.equals(this.prevText) && this.callback != null) { this.callback.onTextChange(this); }
    return this;
  }

  public InputBox setDefaultText(String defaultText) {
    this.defaultText = defaultText;
    if (isEmpty()) { setTextToDefault(); }
    return this;
  }

  public InputBox setTextToDefault() { setText(getDefaultText()); return this; }

  public InputBox setCallback(InputBoxCallback callback) { this.callback = callback; return this; }
  public InputBox catchFocus() { this.onFocus = true; return this; }
  public InputBox dropFocus() {
    this.onFocus = false;
    if (isEmpty()) { setTextToDefault(); }
    return this;
  }

  public int length() { return getText().length(); }
  public int getMaxLen() { return this.maxLen; }
  public boolean isEmpty() { return length() <= 0; }
  public String getDefaultText() { return this.defaultText; }
  public boolean isOnFocus() { return this.onFocus; }
  public String getPrevText() { return this.prevText; }

  @Override
  public void onKeyboardEvent(KeyboardEvent e) {
    if (!isOnFocus()) { return; }
    if (e instanceof KeyPressedEvent) {
      onKeyPressedEvent((KeyPressedEvent)e);
    }
  }

  public void onKeyPressedEvent(KeyPressedEvent e) {
    int key = e.getKey();
    switch (key) {
      case ENTER: case RETURN: case ESC: { dropFocus(); break; }
      case BACKSPACE: case DELETE: { tryDeleteLast(); break; }
    }
    // Accept only ASCII printable characters, i.e., in range [32, 127].
    if (' ' <= key && key <= '~') { tryAppend(key); }
  }

  public void tryDeleteLast() {
    if (isEmpty()) { return; }
    String newStr = getText().substring(0, length() - 1);
    setText(newStr);
  }

  public void tryAppend(int key) {
    if (length() >= getMaxLen()) { return; }
    String newStr = getText() + (char)key;
    setText(newStr);
  }

  @Override
  public void onMouseEvent(MouseEvent e) {
    if (e instanceof MouseClickedEvent) {
      MouseClickedEvent click = (MouseClickedEvent)e;
      if (isMouseEventRelated(click)) { catchFocus(); }
      else { dropFocus(); }
    }
  }

  @Override
  public void draw() {
    fill(255);
    rect(getX(), getY(), getW(), getH());
    super.draw();
  }
}
