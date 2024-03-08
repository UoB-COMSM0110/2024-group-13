String imagePathStartPageBackground = "data/GUI/BackgroundEarthImage.png";
PImage imageStartPageBackground;
String imagePathGameBanner = "data/GUI/GameBanner.png";
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

    Button playButton = new Button("Play", 300, 350, "Play");
    playButton.setW(200).setH(40);
    addLocalItem(playButton);

    Button helpButton = new Button("Help", 300, 390, "Help");
    helpButton.setW(200).setH(40);
    addLocalItem(helpButton);
  }



  @Override
  public void draw(GameInfo gInfo) {
    image(imageStartPageBackground, 0, 0, 800, 600);
    image(imageGameBanner,145,150, 509, 165);
    super.draw(gInfo);
  }
}
