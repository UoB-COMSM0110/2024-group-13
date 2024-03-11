// The first page of the game.
public class PlayerPage extends Page {
  public PlayerPage(GameInfo gInfo, Page previousPage) {
    super(gInfo, previousPage);

    Button backButton = new Button("Back", 300, 350, "Back");
    backButton.setW(200).setH(40);
    addLocalItem(backButton);

    Button startButton = new Button("Start", 300, 420, "Start");
    startButton.setW(200).setH(40);
    addLocalItem(startButton);

  }


  
  @Override
  public void draw(GameInfo gInfo) {
    PImage backgroundImage = loadImage("data/GUI/BackgroundEarthImage.png");
    image(backgroundImage, 0, 0, 800, 600);
    super.draw(gInfo);
  }
}
