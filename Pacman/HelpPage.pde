// The first page of the game.
public class HelpPage extends Page {
  public HelpPage(GameInfo gInfo, Page previousPage) {
    super(gInfo, previousPage);

    Button backButton = new Button("Back", 300, 350, "Back");
    backButton.setW(200).setH(40);
    addLocalItem(backButton);

  }
  

  string imagePathOverlay = "data/GamePageOverlay.png";
  PImage imagePathOverlay;

  if (imageOverlay == null) {
      imageOverlay = loadImage(imagePathOverlay);
  }

  

  
  @Override
  public void draw(GameInfo gInfo) {
    image(imageStartPageBackground, 0, 0, 800, 600);
    image(imageOverlay, 0, 0, 800, 600);
    super.draw(gInfo);
  }
}
