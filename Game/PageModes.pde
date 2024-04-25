// The page for choosing modes: single host, or LAN online.
public class ModesPage extends Page {
  public ModesPage(Page previousPage) {
    super("modes", previousPage);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(getPreviousPage()); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);

    // Local Mode button
    Button localGameButton = new Button("ButtonLocalGame", 200, 50, "Local  Mode",
        () -> { trySwitchPage(new LocalModePage(this)); });
    localGameButton.setCenterX(gameInfo.getWinWidth() / 2.0).setY(300);
    addLocalItem(localGameButton);

    // Online Mode button
    Button onlineGameButton = new Button("ButtonOnlineGame",
        localGameButton.getW(), localGameButton.getH(), "Online  Mode",
        () -> { trySwitchPage(new OnlineModePage(this)); });
    onlineGameButton.setX(localGameButton.getX()).setTopY(localGameButton.getBottomY() + 10);
    addLocalItem(onlineGameButton);

    // Modes Help button
    Button gameModesButton = new Button("GameModesHelp",
        localGameButton.getW(), localGameButton.getH(), "Modes  Help",
        () -> { trySwitchPage(new HelpPage6(this, this)); });
    gameModesButton.setX(onlineGameButton.getX()).setTopY(onlineGameButton.getBottomY() + 40);
    addLocalItem(gameModesButton);
  }
  
  @Override
  public void drawBackground() {
      float winWidth = gameInfo.getWinWidth();
      float winHeight = gameInfo.getWinHeight();
      image(imageStartPageBackground, 0, 0, winWidth, winHeight);
      drawTextWithOutline("Let's  Play !", gameInfo.getWinWidth() / 2, 200, 80, 3, color(255));
  }
}
