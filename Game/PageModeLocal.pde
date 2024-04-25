// The page for starting a local game.
public class LocalModePage extends Page {
  public LocalModePage(Page previousPage) {
    super("localmode", previousPage);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(getPreviousPage()); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);

    // Start button
    Button startButton = new Button("ButtonStart", 200, 50, "Start",
        () -> { trySwitchPage(new PlayPage(this)); });
    startButton.setCenterX(gameInfo.getWinWidth() / 2.0).setY(500);
    addLocalItem(startButton);

    // Player name 1
    Label playerNamePrompt1 = new Label("PlayerNamePrompt1",
        150, 35, "Player 1 : ");
    playerNamePrompt1.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft)
      .setRightX(170).setY(330);
    addLocalItem(playerNamePrompt1);
    InputBox playerName1 = new InputBox("InputBoxPlayerName1",
        210, playerNamePrompt1.getH(), 15, (bx, oStr, nStr) -> {
        gameInfo.setPlayerName1(nStr);
        onPlayerNameSet();
    });
    playerName1.setDefaultText("Happy Bunny")
      .setUpdater(() -> { playerName1.setText(gameInfo.getPlayerName1()); })
      .setLeftX(playerNamePrompt1.getRightX()).setY(playerNamePrompt1.getY());
    addLocalItem(playerName1);
    // Player name 2
    Label playerNamePrompt2 = new Label("PlayerNamePrompt2",
        playerNamePrompt1.getW(), playerNamePrompt1.getH(), "Player 2 : ");
    playerNamePrompt2.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft)
      .setX(playerNamePrompt1.getX()).setTopY(playerNamePrompt1.getBottomY() + 20);
    addLocalItem(playerNamePrompt2);
    InputBox playerName2 = new InputBox("InputBoxPlayerName2",
        playerName1.getW(), playerName1.getH(), playerName1.getMaxLen(), (bx, oStr, nStr) -> {
        gameInfo.setPlayerName2(nStr);
        onPlayerNameSet();
    });
    playerName2.setDefaultText("Merry Kitty")
      .setUpdater(() -> { playerName2.setText(gameInfo.getPlayerName2()); })
      .setLeftX(playerNamePrompt2.getRightX()).setY(playerNamePrompt2.getY());
    addLocalItem(playerName2);
  }

  public void onPlayerNameSet() {
    Button startButton = (Button)getLocalItem("ButtonStart");
    boolean enable = !gameInfo.getPlayerName1().isEmpty() && !gameInfo.getPlayerName2().isEmpty();
    if (enable) { startButton.enable(); }
    else { startButton.disable(); }
  }
  
  @Override
  public void drawBackground() {
      float winWidth = gameInfo.getWinWidth();
      float winHeight = gameInfo.getWinHeight();
      image(imageStartPageBackground, 0, 0, winWidth, winHeight);
      drawTextWithOutline("Local  Game  Setup", 400, 220, 80, 3, color(255));
  }
}
