// The first page of the game.
public class HomePage extends Page {
  public HomePage() {
    super("home", null);

    // Play button
    Button playButton = new Button("ButtonPlay", 200, 50, "Play",
        () -> { trySwitchPage(new ModesPage(this)); });
    playButton.setCenterX(gameInfo.getWinWidth() / 2.0).setY(350);
    addLocalItem(playButton);

    // Tutorial button
    Button tutorialButton = new Button("TutorialHelp", playButton.getW(), playButton.getH(),
        "Tutorial", () -> { trySwitchPage(new HelpPage1(this, this)); });
    tutorialButton.setX(playButton.getX()).setTopY(playButton.getBottomY() + 30);
    addLocalItem(tutorialButton);
  }

  @Override
  public void drawBackground() {
      float winWidth = gameInfo.getWinWidth();
      float winHeight = gameInfo.getWinHeight();
      image(imageStartPageBackground, 0, 0, winWidth, winHeight);
      drawTextWithOutline("PAC-MINER", 400, 220, 80, 3, color(255));
  }
}
