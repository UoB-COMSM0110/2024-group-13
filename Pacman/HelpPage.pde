// The first page of the game.
public class HelpPage extends Page {
  public HelpPage(GameInfo gInfo, Page previousPage) {
    super(gInfo, previousPage);

    Button backButton = new Button("Back", 300, 350, "Back");
    backButton.setW(200).setH(40);
    addLocalItem(backButton);

  }

  String imagePathOverlay = "data/GamePageOverlay.png";
  PImage imageOverlay;
  String imagePathInstructionSet = "data/instructionSet.png";
  PImage imageInstructionSet;

  @Override
  public void draw(GameInfo gInfo) {
    image(imageStartPageBackground, 0, 0, 800, 600);
    if (imageOverlay == null) {
        imageOverlay = loadImage(imagePathOverlay);
    }
    image(imageOverlay, 0, 0, 800, 600);
    if (imageInstructionSet == null) {
        imageInstructionSet = loadImage(imagePathInstructionSet);
    }
    image(imageInstructionSet, 10, 100, 780, 390);
    super.draw(gInfo);
  }
}
