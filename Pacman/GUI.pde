String imagePathButton = "data/Button.png";
PImage imageButton;

int fontSizeMinecraft = 20;
String fontPathMinecraft = "data/Minecraft.ttf";
PFont fontMinecraft;
  
public class Button extends LocalItem {
  String text;
  int textColor;
  int textSize;
  PFont textFont;
  
  public Button(String name, float w, float h, String text) {
    super(name, w, h);
    this.text = text;
    this.textColor = color(100, 20, 20);
    this.textSize = fontSizeMinecraft;
    if (fontMinecraft == null) {
      fontMinecraft = createFont(fontPathMinecraft, fontSizeMinecraft);
    }
    this.textFont = fontMinecraft;
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
    if(text == "Play"){
      GamePage gamePage = new GamePage(gInfo, game.page);
      game.page = gamePage;
    }
    else if (text == "Help"){
      HelpPage helpPage = new HelpPage(gInfo, game.page);
      game.page = helpPage;
    }
    else if(text == "Back"){
      game.page  = game.page.previousPage;
    }
    else if(text == "Start"){
      GamePage gamePage = new GamePage(gInfo, game.page);
      game.page = gamePage;
    }
  }

  @Override
  public PImage getImage() {
    if (imageButton == null) { imageButton = loadImage(imagePathButton); }
    return imageButton;
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
