// The first page of the game.
public class HelpPage extends Page {
  public HelpPage(GameInfo gInfo, Page previousPage) {
    super(gInfo, previousPage);

    Button backButton = new Button("Back", 300, 350, "Back");
    backButton.setW(200).setH(40);
    addLocalItem(backButton);

  }


  
  @Override
  public void draw(GameInfo gInfo) {
    PImage backgroundImage = loadImage("data/GUI/BackgroundEarthImage.png");
    image(backgroundImage, 0, 0, 800, 600);
    super.draw(gInfo);
  }
}
