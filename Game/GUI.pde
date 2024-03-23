final String imagePathButton = "data/Button.png";
PImage imageButton;
final String fontPathMinecraft = "data/Minecraft.ttf";
PFont fontMinecraft;

void loadResourcesForGui() {
  imageButton = loadImage(imagePathButton);
  fontMinecraft = createFont(fontPathMinecraft, fontSizeMinecraft);
}


int fontSizeMinecraft = 20;
  
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
    this.textFont = fontMinecraft;
  }

  @Override
  void onMouseEvent(GameInfo gInfo, Page page, MouseEvent e) {
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
      GamePage gamePage = new GamePage(gInfo, page);
      page = gamePage;
    }
    else if (text == "Help"){
      HelpPage helpPage = new HelpPage(gInfo, page);
      page = helpPage;
    }
    else if(text == "Back"){
      page  = page.previousPage;
    }
    else if(text == "Start"){
      GamePage gamePage = new GamePage(gInfo, page);
      page = gamePage;
    }
  }

  @Override
  public PImage getImage() {
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
