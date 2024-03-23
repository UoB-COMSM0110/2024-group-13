String imagePathStartPageBackground = "data/StartPageBackground.png";
PImage imageStartPageBackground;
String imagePathGameBanner = "data/GameBanner.png";
PImage imageGameBanner;

// The first page of the game.
public class StartPage extends Page {
  public StartPage(GameInfo gInfo, Page previousPage) {
    super(gInfo, previousPage);
    
    if (imageStartPageBackground == null) {
      imageStartPageBackground = loadImage(imagePathStartPageBackground);
    }
    if (imageGameBanner == null) {
      imageGameBanner = loadImage(imagePathGameBanner);
    }

    Button playButton = new Button("Play", 200, 40, "Play");
    playButton.setX(300).setY(350);
    addLocalItem(playButton);

    Button helpButton = new Button("Help", 200, 40, "Help");
    helpButton.setX(300).setY(390);
    addLocalItem(helpButton);
  }

  @Override
  public void draw(GameInfo gInfo) {
    image(imageStartPageBackground, 0, 0, 800, 600);
    image(imageGameBanner,145,150, 509, 165);
    super.draw(gInfo);
  }
}
