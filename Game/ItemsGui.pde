final int textColorDefault = color(100, 20, 20);
final int textColorDisabled = color(100, 100, 100);
final int textSizeDefault = 20;


// A rectangular area which might contain an image.
public class RectArea extends LocalItem {
  private boolean drawBox; // whether to draw border box.
  private float boxStrokeWeight;
  private int boxStrokeColor;
  private boolean boxFill;
  private int boxFillColor;
  private float boxRadius;
  private PImage image;

  public RectArea(String name, float w, float h) {
    super(name, w, h);
    this.boxFill = true;
    this.boxFillColor = 255;
  }

  public RectArea setDrawBox(boolean drawBox) { this.drawBox = drawBox; return this; }
  public RectArea setBoxStrokeWeight(float boxStrokeWeight) { this.boxStrokeWeight = boxStrokeWeight; return this; }
  public RectArea setBoxStrokeColor(int boxStrokeColor) { this.boxStrokeColor = boxStrokeColor; return this; }
  public RectArea setBoxFill(boolean fill) { this.boxFill = fill; return this; }
  public RectArea setBoxFillColor(int boxFillColor) { this.boxFillColor = boxFillColor; return this; }
  public RectArea setBoxRadius(float boxRadius) { this.boxRadius = boxRadius; return this; }
  public RectArea setImage(PImage image) { this.image = image; return this; }

  public float getBoxRadius() { return this.boxRadius; }

  @Override
  public PImage getImage() { return this.image; }

  @Override
  public void draw() {
    if (this.drawBox) { drawBox(); }
    super.draw();
  }

  public void drawBox() {
    strokeWeight(this.boxStrokeWeight);
    stroke(this.boxStrokeColor);
    if (this.boxFill) { fill(this.boxFillColor); }
    else { noFill(); }
    float x = getX() + this.boxStrokeWeight / 2.0;
    float y = getY() + this.boxStrokeWeight / 2.0;
    float w = getW() - this.boxStrokeWeight;
    float h = getH() - this.boxStrokeWeight;
    rect(x, y, w, h, getBoxRadius());
  }
}
  

// A rectangular area which might contains text.
public class Label extends RectArea {
  private String prefix;
  private String text;
  private int textColor;
  private int textSize;
  private PFont textFont;
  private int textAlignHorizon;
  private int textAlignVertical;
  private Action updater; // The updater will be called for each frame. Can be used to update text.

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
  public Label setTextAlignVertical(int align) { this.textAlignVertical = align; return this; }
  public Label setUpdater(Action updater) { this.updater = updater; return this; }

  public String getText() { return this.text; }
  public String getPrefix() { return this.prefix; }
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

  public void drawTextContent() {
    float margin = 5.0;
    float alignPointX = getX();
    float alignPointY = getY();
    switch (this.textAlignHorizon) {
      case LEFT: { alignPointX = getLeftX() + margin; break; }
      case CENTER: { alignPointX = getCenterX(); break; }
      case RIGHT: { alignPointX = getRightX() - margin; break; }
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
    text(getDrawnTextContent(), alignPointX, alignPointY);
  }

  public String getDrawnTextContent() { return this.prefix + this.text; }
}


// A label that reacts to user event.
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
  private Action action; // What to do if clicked?

  private boolean hovering; // Whether the cursor is on hovering on this button?
  private float zoomRatio;

  public Button(String name, float w, float h, String text) {
    this(name, w, h, text, null);
  }

  public Button(String name, float w, float h, String text, Action action) {
    super(name, w, h, text);
    setImage(imageButton);
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
}


@FunctionalInterface
public static interface TextChangeCallback {
  void onTextChange(InputBox inputBox, String oldStr, String newStr);
}

public class InputBox extends InteractiveWidget {
  private String defaultText; // This `defaultText` feature is currently not used.
  private String promptText;
  private int maxLen; // Max characters that the user can enter.
  private TextChangeCallback callback; // What to do if text changed?

  private boolean onFocus;

  public InputBox(String name, float w, float h, int maxLen) {
    this(name, w, h, maxLen, null);
  }

  public InputBox(String name, float w, float h, int maxLen, TextChangeCallback callback) {
    super(name, w, h, "");
    this.defaultText = "";
    this.promptText = "";
    this.maxLen = maxLen;
    this.callback = callback;
    this.onFocus = false;
    setDrawBox(true);
    setBoxRadius(3.0);
  }

  public InputBox setDefaultText(String defaultText) {
    this.defaultText = defaultText;
    if (isEmpty() && !isDisabled()) { changeText(getDefaultText()); }
    return this;
  }

  public InputBox setPromptText(String promptText) {
    this.promptText = promptText;
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
      this.callback.onTextChange(this, prevText, text);
    }
    return this;
  }

  public void catchFocus() { this.onFocus = true; }
  public void dropFocus() {
    this.onFocus = false;
    if (isEmpty() && !isDisabled()) { changeText(getDefaultText()); }
  }

  public int length() { return getText().length(); }
  public int getMaxLen() { return this.maxLen; }
  public boolean isEmpty() { return length() <= 0; }
  public String getDefaultText() { return this.defaultText; }
  public String getPromptText() { return this.promptText; }
  public boolean isOnFocus() { return this.onFocus; }

  @Override
  public InputBox disable() {
    super.disable();
    dropFocus();
    return this;
  }

  @Override
  public InputBox enable() {
    super.enable();
    if (isEmpty()) { changeText(getDefaultText()); }
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
  public String getDrawnTextContent() {
    String text = getText();
    if (text.length() <= 0 && !isOnFocus()) { text = getPromptText(); }
    return getPrefix() + text;
  }

  @Override
  public void drawTextContent() {
    if (isOnFocus()) { shade(); }
    super.drawTextContent();
  }

  public void shade() {
    float step = 1.0;
    int nStep = 8;
    strokeWeight(step);
    noFill();
    int c = color(0, 200, 200);
    for (int i = 0; i < nStep; ++i) {
      float x = getX() + step * (i + 0.5);
      float y = getY() + step * (i + 0.5);
      float w = getW() - (2 * i + 1) * step;
      float h = getH() - (2 * i + 1) * step;
      float alpha = 255.0 * (1.0 - i * 1.0 / nStep);
      stroke(c, alpha);
      rect(x, y, w, h, getBoxRadius());
    }
  }
}
