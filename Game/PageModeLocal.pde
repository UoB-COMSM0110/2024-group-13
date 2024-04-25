import java.util.List;

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
    startButton.setCenterX(gameInfo.getWinWidth() / 2.0).setY(600);
    addLocalItem(startButton);

    addLocalItems(createPlayerWidgets(1, 320, 330));
    addLocalItems(createPlayerWidgets(2, 320, 385));
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
      drawTextWithOutline("Local  Game", 400, 220, 80, 3, color(255));
  }

  public List<LocalItem> createPlayerWidgets(int playerId, float xOffset, float yOffset) {
    ArrayList<LocalItem> items = new ArrayList<LocalItem>();

    Label playerNamePrompt = new Label("PlayerNamePrompt" + playerId, 150, 35,
        "Player " + playerId + " : ");
    playerNamePrompt.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft)
      .setRightX(xOffset).setTopY(yOffset);
    items.add(playerNamePrompt);
    InputBox playerName = new InputBox("InputBoxPlayerName" + playerId,
        210, playerNamePrompt.getH(), 15, (bx, oStr, nStr) -> {
        gameInfo.setPlayerName1(nStr);
        onPlayerNameSet();
    });

    String defaultName = playerId == 1 ? "Happy Bunny" : "Merry Kitty";
    playerName.setDefaultText(defaultName)
      .setUpdater(() -> { playerName.setText(gameInfo.getPlayerName(playerId)); })
      .setLeftX(playerNamePrompt.getRightX()).setY(playerNamePrompt.getY());
    items.add(playerName);

    return items;
  }
}
