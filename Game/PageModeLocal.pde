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
    startButton.disable().setCenterX(gameInfo.getWinWidth() / 2.0).setY(530);
    addLocalItem(startButton);

    // Start instruction
    int textSize = 14;
    Label simpleInstruct = new Label("CreateInstruct", 320, textSize,
        "Enter players' names first, then let's start!");
    simpleInstruct.setTextSize(textSize).setTextAlignHorizon(CENTER).setTextFont(fontSFPro)
      .setCenterX(startButton.getCenterX()).setBottomY(startButton.getTopY() - 5);
    addLocalItem(simpleInstruct);
    // simpleInstruct.setDrawBox(true);

    addLocalItems(createPlayerWidgets(1, 100, 300, () -> { onPlayerNameSet(); }));
    addLocalItems(createPlayerWidgets(2, 500, 300, () -> { onPlayerNameSet(); }));
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
      drawTextWithOutline("Local  Game", gameInfo.getWinWidth() / 2, 200, 80, 3, color(255));
  }
}


public List<LocalItem> createPlayerWidgets(int playerId, float xOffset, float yOffset,
    Action onPlayerNameSet) {
  ArrayList<LocalItem> items = new ArrayList<LocalItem>();

  RectArea playerBanner = new RectArea("PlayerBanner" + playerId, 220, 45);
  PImage imgBanner = playerId == 1 ? imagePlayerBanner1 : imagePlayerBanner2;
  playerBanner.setImage(imgBanner).setLeftX(xOffset).setTopY(yOffset);
  items.add(playerBanner);

  InputBox playerName = new InputBox("InputBoxPlayerName" + playerId, 210, 30, 15,
      (bx, oStr, nStr) -> {
        gameInfo.setPlayerName(playerId, nStr);
        onPlayerNameSet.run();
      });
  playerName.setPromptText("Your Name Here")
    .setUpdater(() -> { playerName.setText(gameInfo.getPlayerName(playerId)); })
    .setCenterX(playerBanner.getCenterX() + 30).setTopY(playerBanner.getBottomY() + 5);
  items.add(playerName);

  Label playerNamePrompt = new Label("PlayerNamePrompt" + playerId, 70, playerName.getH(), "NAME:");
  playerNamePrompt.setTextAlignHorizon(RIGHT)
    .setRightX(playerName.getLeftX()).setY(playerName.getY());
  items.add(playerNamePrompt);

  PImage imgKeyset = playerId == 1 ? imageKeyset1 : imageKeyset2;
  RectArea keyset = new RectArea("InstructionKeyset" + playerId, 240, 60);
  keyset.setImage(imgKeyset)
    .setX(playerBanner.getX() + 10).setTopY(playerName.getBottomY() + 25);
  items.add(keyset);

  Label keyMove = new Label("KeyMove" + playerId, 50, 15, "move:");
  keyMove.setTextSize(15).setLeftX(keyset.getLeftX() - 30).setTopY(keyset.getTopY() - 6);
  items.add(keyMove);
  Label keyFire = new Label("KeyFire" + playerId, 100, 15, "explosive:");
  keyFire.setTextSize(15).setLeftX(keyset.getLeftX() + 120).setTopY(keyset.getTopY() - 6);
  items.add(keyFire);

  float boxLeft = playerNamePrompt.getLeftX() - 20;
  float boxRight = playerName.getRightX() + 20;
  float boxTop = playerBanner.getTopY() - 20;
  float boxBottom = keyset.getBottomY() + 20;
  RectArea playerBox = new RectArea("PlayerBox" + playerId, boxRight - boxLeft, boxBottom - boxTop);
  playerBox.setDrawBox(true).setBoxFillColor(color(205, 147, 102))
    .setBoxStrokeWeight(3).setBoxStrokeColor(color(96, 32, 32)).setBoxRadius(5)
    .setLayer(-1).setLeftX(boxLeft).setTopY(boxTop);
  items.add(playerBox);

  // // For debug
  // playerNamePrompt.setDrawBox(true);
  // keyMove.setDrawBox(true);
  // keyFire.setDrawBox(true);

  return items;
}
