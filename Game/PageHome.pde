// The first page of the game.
public class HomePage extends Page {
  public HomePage() {
    super("home", null);

    // Play button
    Button playButton = new Button("ButtonPlay", 200, 50, "Play",
        () -> { trySwitchPage(new ModesPage(this)); });
    playButton.setCenterX(gameInfo.getWinWidth() / 2.0).setY(500);
    addLocalItem(playButton);
    // Tutorial button
    Button tutorialButton = new Button("TutorialHelp", playButton.getW(), playButton.getH(),
        "Tutorial", () -> { trySwitchPage(new HelpPage1(this)); });
    tutorialButton.setX(playButton.getX()).setTopY(playButton.getBottomY() + 10);
    addLocalItem(tutorialButton);
    // Game Modes button
    Button gameModesButton = new Button("GameModesHelp", playButton.getW(), playButton.getH(),
        "Game  Modes", () -> { trySwitchPage(new HelpPage6(this)); });
    gameModesButton.setX(playButton.getX()).setTopY(tutorialButton.getBottomY() + 10);
    addLocalItem(gameModesButton);
  }

  @Override
  public void drawBackground() {
      float winWidth = gameInfo.getWinWidth();
      float winHeight = gameInfo.getWinHeight();
      image(imageStartPageBackground, 0, 0, winWidth, winHeight);
      drawTextWithOutline("PAC-MINER", 400, 220, 80, 3, color(255));
  }
}
