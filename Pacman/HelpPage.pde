// The first page of the game.
public class HelpPage extends Page {
  public HelpPage(GameInfo gInfo, Page previousPage) {
    super(gInfo, previousPage);

    Button backButton = new Button("Back", 300, 350, "Back");
    backButton.setW(200).setH(40);
    backButton.setX(55).setY(28);
    addLocalItem(backButton);

  }
  

  String imagePathOverlay = "data/GamePageOverlay.png";
  PImage imageOverlay = loadImage(imagePathOverlay);
  
  String instructionSet = "data/instructionSet.png";
  PImage instructionImage = loadImage(instructionSet);
  
  
  
  int fontSizeMinecraft = 20;
  String fontPathMinecraft = "data/Minecraft.ttf";
  PFont fontMinecraft;
  
  
  @Override
  public void draw(GameInfo gInfo) {
    image(imageStartPageBackground, 0, 0, 800, 600);
    image(imageOverlay, 0, 0, 800, 600);
    image(instructionImage, 58, 150, 720, 334);
    fill(255);
    textSize(25);
    text("Pac-miner: A Subterranean Adventure", 300, 110);
    super.draw(gInfo);
  }
}