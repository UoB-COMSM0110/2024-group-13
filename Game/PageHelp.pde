final String imagePathHelpPageOverlay = "data/HelpPageOverlay.png";
final String instructionSet = "data/InstructionSet.png";

// The first page of the game.
public class HelpPage extends Page {
  private PImage imageOverlay;
  private PImage instructionImage;
  
  public HelpPage(Page previousPage) {
    super(previousPage);
    this.imageOverlay = loadImage(imagePathHelpPageOverlay);
    this.instructionImage = loadImage(instructionSet);

    Button backButton = new Button("ButtonBack", 200, 40, "Back", () -> {
      trySwitchPage(getPreviousPage());
    });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
  }

  @Override
  public void draw() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageOverlay, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
    fill(255);
    textSize(25);
    text("Pac-miner: A Subterranean Adventure", 300, 110);
    super.draw();
  }
}
