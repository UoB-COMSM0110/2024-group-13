final int textColorDefault = color(100, 20, 20);
final int textColorDisabled = color(100, 100, 100);
final int textSizeDefault = 20;
final String imagePathButton = "data/Button.png";
PImage imageButton;
final String fontPathMinecraft = "data/Minecraft.ttf";
PFont fontMinecraft;
final String fontPathErikaType = "data/ErikaType.ttf";
PFont fontErikaType;

void loadResourcesForGui() {
  imageButton = loadImage(imagePathButton);
  fontMinecraft = createFont(fontPathMinecraft, textSizeDefault, true);
  fontErikaType = createFont(fontPathErikaType, textSizeDefault, true);
}

  
public class Label extends LocalItem {
  private String prefix;
  private String text;
  private int textColor;
  private int textSize;
  private PFont textFont;
  private int textAlignHorizon;
  private int textAlignVertical;
  private Action updater;

  public Label(String name, float w, float h, String text) {
    super(name, w, h);
    this.prefix = "";
    this.text = text;
    this.textColor = textColorDefault;
    this.textSize = textSizeDefault;
    this.textFont = fontErikaType;
    this.textAlignHorizon = LEFT;
    this.textAlignVertical = CENTER;
  }

  public Label setPrefix(String prefix) { this.prefix = prefix; return this; }
  public Label setText(String text) { this.text = text; return this; }
  public Label setTextColor(int textColor) { this.textColor = textColor; return this; }
  public Label setTextSize(int textSize) { this.textSize = textSize; return this; }
  public Label setTextFont(PFont textFont) { this.textFont = textFont; return this; }
  public Label setTextAlignHorizon(int align) { this.textAlignHorizon = align; return this; }
  public Label setUpdater(Action updater) { this.updater = updater; return this; }

  public String getText() { return this.text; }
  public int getTextDrawColor() { return this.textColor; }

  @Override
  public void update() {
    if (this.updater != null) { this.updater.run(); }
  }

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
    noStroke();
    fill(getTextDrawColor());
    textFont(this.textFont, this.textSize);
    textAlign(this.textAlignHorizon, this.textAlignVertical);
    text(this.prefix + this.text, alignPointX, alignPointY);
  }
}


public abstract class InteractiveWidget extends Label {
  boolean disabled;

  public InteractiveWidget(String name, float w, float h, String text) {
    super(name, w, h, text);
    this.disabled = false;
  }

  public InteractiveWidget disable() { this.disabled = true; return this; }
  public InteractiveWidget enable() { this.disabled = false; return this; }

  public boolean isDisabled() { return this.disabled; }

  @Override
  public int getTextDrawColor() {
    if (isDisabled()) { return textColorDisabled; }
    else { return super.getTextDrawColor(); }
  }

  @Override
  public void onEvent(Event e) {
    if (isDisabled()) { return; }
    else { super.onEvent(e); }
  }
}


public class Button extends InteractiveWidget {
  private Action action;

  private boolean hovering;
  private float zoomRatio;

  public Button(String name, float w, float h, String text) {
    this(name, w, h, text, null);
  }

  public Button(String name, float w, float h, String text, Action action) {
    super(name, w, h, text);
    setTextFont(fontMinecraft).setTextAlignHorizon(CENTER);
    this.action = action;
    this.hovering = false;
    this.zoomRatio = 1.02;
  }

  Button setAction(Action action) { this.action = action; return this; }

  @Override
  public Button disable() {
    super.disable();
    onHoverOff();
    return this;
  }

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
public static interface TextChangeCallback {
  void onTextChange(InputBox inputBox);
}

public class InputBox extends InteractiveWidget {
  private String defaultText;
  private int maxLen;
  private TextChangeCallback callback;

  private boolean onFocus;

  public InputBox(String name, float w, float h, int maxLen) {
    this(name, w, h, maxLen, null);
  }

  public InputBox(String name, float w, float h, int maxLen, TextChangeCallback callback) {
    super(name, w, h, "");
    this.defaultText = "";
    this.maxLen = maxLen;
    this.callback = callback;
    this.onFocus = false;
  }

  public InputBox setDefaultText(String defaultText) {
    this.defaultText = defaultText;
    if (isEmpty()) { setTextToDefault(); }
    return this;
  }

  public InputBox setCallback(TextChangeCallback callback) {
    this.callback = callback;
    return this;
  }

  public InputBox changeText(String text) {
    String prevText = getText();
    setText(text);
    if (!text.equals(prevText) && this.callback != null) {
      this.callback.onTextChange(this);
    }
    return this;
  }

  public InputBox setTextToDefault() { return changeText(getDefaultText()); }

  public void catchFocus() { this.onFocus = true; }
  public void dropFocus() {
    this.onFocus = false;
    if (isEmpty()) { setTextToDefault(); }
  }

  public int length() { return getText().length(); }
  public int getMaxLen() { return this.maxLen; }
  public boolean isEmpty() { return length() <= 0; }
  public String getDefaultText() { return this.defaultText; }
  public boolean isOnFocus() { return this.onFocus; }

  @Override
  public InputBox disable() {
    super.disable();
    dropFocus();
    return this;
  }

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
      case TAB: case ENTER: case RETURN: case ESC: { dropFocus(); break; }
      case BACKSPACE: case DELETE: { tryDeleteLast(); break; }
    }
    // Accept only ASCII printable characters, i.e., in range [32, 127].
    if (' ' <= key && key <= '~') { tryAppend(key); }
  }

  public void tryDeleteLast() {
    if (isEmpty()) { return; }
    String newStr = getText().substring(0, length() - 1);
    changeText(newStr);
  }

  public void tryAppend(int key) {
    if (length() >= getMaxLen()) { return; }
    String newStr = getText() + (char)key;
    changeText(newStr);
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
    strokeWeight(0.0);
    fill(255);
    rect(getX(), getY(), getW(), getH(), 3);
    if (isOnFocus()) { shade(); }
    super.draw();
  }

  public void shade() {
    float step = 1.0;
    int nStep = 10;
    strokeWeight(step);
    noFill();
    for (int i = 0; i < nStep; ++i) {
      float x = getX() + step * i;
      float y = getY() + step * i;
      float w = getW() - 2 * step * i;
      float h = getH() - 2 * step * i;
      int c = color(0, 200, 200);
      float alpha = 255.0 * (1.0 - i * 1.0 / nStep);
      stroke(c, alpha);
      rect(x, y, w, h, 3);
    }
  }
}
