final String imagePathStartPageBackground = "data/StartPageBackground.png";
PImage imageStartPageBackground;
final String imagePathGameBanner = "data/GameBanner.png";


// The first page of the game.
public class StartPage extends Page {
  private PImage imageGameBanner;

  public StartPage(Page previousPage) {
    super(previousPage);
    imageStartPageBackground = loadImage(imagePathStartPageBackground);
    this.imageGameBanner = loadImage(imagePathGameBanner);

    Button playButton = new Button("ButtonPlay", 200, 40, () -> {
      trySetNextPage(new PlayPage(this));
    });
    playButton.setX(300).setY(350);
    addLocalItem(playButton);

    Button helpButton = new Button("ButtonHelp", 200, 40, () -> {
      trySetNextPage(new HelpPage(this));
    });
    helpButton.setX(300).setY(400);
    addLocalItem(helpButton);
  }

  @Override
  public void draw() {
    image(imageStartPageBackground, 0, 0, 800, 600);
    image(this.imageGameBanner,145,150, 509, 165);
    super.draw();
  }
}
