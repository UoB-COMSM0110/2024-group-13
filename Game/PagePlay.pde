final String mapPath = "data/map.csv";
final int PlayPageBackgroundColor = color(155, 82, 52);

final int textSizeBoard = 17;

public class PlayPage extends Page {
  private JSONArray syncDeletesRecord;
  private boolean isGameOver;
  private long gameOverWaitingTimeMs;

  public PlayPage(Page previousPage) {
    super("play", previousPage);
    this.syncDeletesRecord = new JSONArray();

    RectArea localArea = new RectArea("LocalArea",
        gameInfo.getWinWidth(), gameInfo.getMapOffsetY());
    localArea.setDrawBox(true)
      .setBoxStrokeWeight(2.0)
      .setBoxStrokeColor(color(102, 51, 0))
      .setBoxFillColor(color(255, 253, 208))
      .setLayer(-9);
    addLocalItem(localArea);

    Button backButton = new Button("ButtonBack", 120, 35, "End Game",
        () -> { trySwitchPage(getPreviousPage()); });
    backButton.setX(10).setY(5);
    addLocalItem(backButton);

    Label fps = new Label("Fps", backButton.getW(), backButton.getH(), "");
    fps.setPrefix("fps:").setX(backButton.getX()).setTopY(backButton.getBottomY());
    addLocalItem(fps);
    addLocalTimer(new Timer(0.0, 1.0,
          () -> { fps.setText(String.format("%.2f", frameRate)); }));

    createPlayerStatusWidgets(1, 160, 5);
    createPlayerStatusWidgets(2, 480, 5);

    if (!gameInfo.isClientHost()) {
      loadMap(mapPath);
    }
  }

  @Override
  public boolean deleteSyncItem(String name) {
    boolean deleted = super.deleteSyncItem(name);
    if (deleted && gameInfo.isServerHost()) {
      JSONObject record = new JSONObject();
      record.setString("name", name);
      this.syncDeletesRecord.append(record);
    }
    return deleted;
  }

  @Override
  public JSONObject getMsgJsonToClient() {
    if (gameInfo.isServerSendBufferFull()) { return null; }
    return super.getMsgJsonToClient();
  }

  @Override
  public JSONArray getChangesJsonArray() {
    JSONArray changesJson = this.syncDeletesRecord;
    this.syncDeletesRecord = new JSONArray();
    for (SynchronizedItem item : getSyncItems()) {
      JSONObject json = item.getStateJson();
      String str = json.toString();
      if (!str.equals(item.getStoredStateStr())) { // not an efficient way
        item.storeStateStr(str);
        changesJson.append(json);
      }
    }
    return changesJson;
  }

  @Override
  public JSONArray getEventsJsonArray(List<KeyboardEvent> events) {
    return keyboardEventsToJson(events);
  }

  @Override
  public void doEvolve(ArrayList<KeyboardEvent> events) {
    if (!isGameOver()) {
      super.doEvolve(events);
      return;
    }
    if (this.gameOverWaitingTimeMs > 0) {
      this.gameOverWaitingTimeMs -= gameInfo.getLastFrameIntervalMs();
    }
    if (this.gameOverWaitingTimeMs <= 0) {
      goToGameOverPage();
    }
  }

  @Override
  public void solveCollisions() {
    (new CollisionEngine()).solveCollisions(() -> isGameOver());
  }

  public boolean isGameOver() { return this.isGameOver; }
  public void gameOver() {
    this.isGameOver = true;
    this.gameOverWaitingTimeMs = 1000; // 1 second stand-still time.
  }

  public void goToGameOverPage() {
    Pacman pacman1 = (Pacman)getSyncItem(itemTypePacman + 1);
    Pacman pacman2 = (Pacman)getSyncItem(itemTypePacman + 2);
    int playerScore1 = pacman1.getScore();
    int playerScore2 = pacman2.getScore();
    trySwitchPage(new GameOverPage(playerScore1, playerScore2, getPreviousPage()));
  }

  @Override
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) {
      trySwitchPage(getPreviousPage());
      return false;
    }
    String otherPlayerPage = json.getString("page");
    if (!getName().equals(otherPlayerPage)) {
      if (isSwitching()) { return true; }
      if (gameInfo.isClientHost()) {
        onNetworkFailure("server is not playing");
        return false;
      } else {
        if (otherPlayerPage.equals("start")) { return true; }
        if (otherPlayerPage.equals("help")) { return true; }
        onNetworkFailure("client is not playing");
        return false;
      }
    }
    if (json.getString("nextPage").equals("start")) {
      trySwitchPage(getPreviousPage());
    }
    if (gameInfo.isClientHost()) {
      gameInfo.setPlayerName1(json.getString("player1"));
      gameInfo.setPlayerName2(json.getString("player2"));
      if (json.getString("nextPage").equals("gameover")) {
        goToGameOverPage();
      }
    }
    return true;
  }

  @Override
  public void onNetworkFailure(String message) {
    super.onNetworkFailure(message);
    switchPage(new ErrorPage(getPreviousPage(), message));
  }

  @Override
  public void drawBackground() { background(PlayPageBackgroundColor); }

  private void createPlayerStatusWidgets(int playerId, float xOffset, float yOffset) {
    float verticalSpace = 2.0;
    float lineHeight = 15;

    RectArea playerIcon = new RectArea("PlayerIcon" + playerId, 2.0 * lineHeight, 2.0 * lineHeight);
    PImage imgIcon = playerId == 1 ? imagePacman_1_U : imagePacman_2_U;
    playerIcon.setImage(imgIcon).setLeftX(xOffset).setY(yOffset);
    addLocalItem(playerIcon);

    Label playerPrompt = new Label("PlayerPrompt" + playerId, 80, lineHeight, "Player : ");
    playerPrompt.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setLeftX(playerIcon.getRightX()).setTopY(playerIcon.getTopY());
    addLocalItem(playerPrompt);

    String playerNameText = playerId == 1 ? gameInfo.getPlayerName1() : gameInfo.getPlayerName2();
    Label playerName = new Label("PlayerName" + playerId, 180, lineHeight, playerNameText);
    playerName.setTextSize(textSizeBoard).setLeftX(playerPrompt.getRightX()).setY(playerPrompt.getY());
    addLocalItem(playerName);

    Label scorePrompt = new Label("ScorePrompt" + playerId, playerPrompt.getW(), lineHeight, "Score : ");
    scorePrompt.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(playerPrompt.getRightX()).setTopY(playerPrompt.getBottomY() + verticalSpace);
    addLocalItem(scorePrompt);

    Label score = new Label("Score" + playerId, 100, lineHeight, "0");
    score.setTextSize(textSizeBoard).setLeftX(scorePrompt.getRightX()).setY(scorePrompt.getY());
    addLocalItem(score);

    Label healthPrompt = new Label("healthPrompt" + playerId, playerPrompt.getW(), lineHeight, "Health : ");
    healthPrompt.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(scorePrompt.getRightX()).setTopY(scorePrompt.getBottomY() + verticalSpace);
    addLocalItem(healthPrompt);

    for (int i = 1; i <= 3; ++i) {
      float x = healthPrompt.getRightX() + lineHeight * (i - 1) + 3;
      RectArea heart = new RectArea("Heart_" + playerId + "_" + i, lineHeight, lineHeight);
      heart.setImage(imageHeart3).setLeftX(x).setCenterY(healthPrompt.getCenterY());
      addLocalItem(heart);
    }

    RectArea bulletPrompt = new RectArea("BulletsPrompt" + playerId, 40, 12);
    bulletPrompt.setImage(imageBulletPrompt)
      .setLeftX(healthPrompt.getRightX() + 90).setCenterY(healthPrompt.getCenterY());
    addLocalItem(bulletPrompt);

    Label bulletNumber = new Label("BulletNumber" + playerId, 25, lineHeight, "0");
    bulletNumber.setTextSize(textSizeBoard)
      .setLeftX(bulletPrompt.getRightX()).setCenterY(bulletPrompt.getCenterY());
    addLocalItem(bulletNumber);

    Label powerupPrompt = new Label("PowerupPrompt" + playerId, playerPrompt.getW(), lineHeight, "Buff : ");
    powerupPrompt.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(healthPrompt.getRightX()).setTopY(healthPrompt.getBottomY() + verticalSpace);
    addLocalItem(powerupPrompt);

    Label powerupDesc = new Label("PowerupDesc" + playerId, 200, lineHeight, "");
    powerupDesc.setTextSize(textSizeBoard).setLeftX(powerupPrompt.getRightX()).setY(powerupPrompt.getY());
    addLocalItem(powerupDesc);

    PImage imgKeyset = playerId == 1 ? imageKeyset1 : imageKeyset2;
    RectArea keyset = new RectArea("InstructionKeyset" + playerId, 180, 45);
    keyset.setImage(imgKeyset)
      .setLeftX(playerIcon.getCenterX()).setTopY(powerupPrompt.getBottomY() + verticalSpace);
    addLocalItem(keyset);

    RectArea keysetLine = new RectArea("InstructionKeysetLine" + playerId, keyset.getW(), 1);
    keysetLine.setDrawBox(true).setLeftX(keyset.getLeftX()).setBottomY(keyset.getTopY());
    addLocalItem(keysetLine);

    // // For debug use:
    // playerPrompt.setDrawBox(true);
    // playerName.setDrawBox(true);
    // score.setDrawBox(true);
    // bulletNumber.setDrawBox(true);
    // powerupDesc.setDrawBox(true);
    // keyset.setDrawBox(true);
  }

  private void loadMap(String mapPath) {
    generateMapBorders();
    addSyncItem(new ViewShader());

    String[] lines = loadStrings(mapPath);
    for (int row = 0; row <lines.length; row++) {
      String[] values = split(lines[row], ",");
      for (int col = 0; col < values.length; col++) {
        float x = CHARACTER_SIZE / 2 + col * CHARACTER_SIZE;
        float y = CHARACTER_SIZE / 2 + row * CHARACTER_SIZE;
        String value = values[col];
        if (value.equals("1")) { // breakable walls
          BreakableWall breakableWall = new BreakableWall();
          breakableWall.setX(x).setY(y);
          addSyncItem(breakableWall);
        } else if (value.equals("2")) { // indestructable walls
          IndestructableWall indestructableWall = new IndestructableWall();
          indestructableWall.setX(x).setY(y);
          addSyncItem(indestructableWall);
        } else if (value.equals("3")) { // coins
          Coin coin = new Coin();
          coin.setX(x).setY(y);
          addSyncItem(coin);
        } else if (value.equals("4")) { // power-ups
          PowerUp powerUp = generateRandomPowerUp();
          powerUp.setX(x).setY(y);
          addSyncItem(powerUp);
        } else if (value.equals("g")) { // ghosts
          Ghost ghost = new Ghost();
          ghost.setX(x).setY(y);
          addSyncItem(ghost);
        } else if (value.equals("p") || value.equals("q")) { // pacmans
          int playerId = value.equals("p") ? 1 : 2;
          Pacman pacman = new Pacman(playerId);
          pacman.setX(x).setY(y);
          addSyncItem(pacman);
          PacmanShelter pacmanShelter = new PacmanShelter(pacman.getPlayerId());
          pacmanShelter.setCenterX(pacman.getCenterX()).setCenterY(pacman.getCenterY());
          addSyncItem(pacmanShelter);
        }
      }
    }
  }
  
  private void generateMapBorders() {
    float borderSize = CHARACTER_SIZE * 2.0;
    float verticalBorderHeight = 2.0 * borderSize + gameInfo.getMapHeight();
    float horizonBorderWidth = 2.0 * borderSize + gameInfo.getMapWidth();
    Border leftBorder = new Border("LeftBorder", borderSize, verticalBorderHeight, LEFTWARD);
    leftBorder.setX(-borderSize).setY(-borderSize);
    addSyncItem(leftBorder);
    Border rightBorder = new Border("RightBorder", borderSize, verticalBorderHeight, RIGHTWARD);
    rightBorder.setX(gameInfo.getMapWidth()).setY(-borderSize);
    addSyncItem(rightBorder);
    Border topBorder = new Border("TopBorder", horizonBorderWidth, borderSize, UPWARD);
    topBorder.setX(-borderSize).setY(-borderSize);
    addSyncItem(topBorder);
    Border bottomBorder = new Border("BottomBorder", horizonBorderWidth, borderSize, DOWNWARD);
    bottomBorder.setX(-borderSize).setY(gameInfo.getMapHeight());
    addSyncItem(bottomBorder);
  }

  @Override
  public float[] getLocalCoord(float x, float y, float w, float h) {
    float[] factoredCoord = getFactoredCoord(x, y, w, h);
    return super.getLocalCoord(factoredCoord[0], factoredCoord[1],
        factoredCoord[2], factoredCoord[3]);
  }

  // Place pacman at the center.
  public float[] getFactoredCoord(float x, float y, float w, float h) {
    float[] coord = new float[4];
    float factor = 1.0;
    float anchorX = gameInfo.getMapWidth() / 2.0;
    float anchorY = gameInfo.getMapHeight() / 2.0;
    if (!gameInfo.isSingleHost()) {
      int playerId = gameInfo.isServerHost() ? 1 : 2;
      Pacman pacman = (Pacman)getSyncItem(itemTypePacman + playerId);
      factor = pacman.getViewFactor();
      anchorX = pacman.getCenterX();
      anchorY = pacman.getCenterY();
    }
    factor = Math.min(Math.max(0.1, factor), 1.0);
    anchorX /= factor;
    anchorY /= factor;
    x /= factor;
    y /= factor;
    w /= factor;
    h /= factor;
    float offsetX = anchorX - gameInfo.getMapWidth() / 2.0;
    float maxOffsetX = gameInfo.getMapWidth() / factor - gameInfo.getMapWidth();
    offsetX = Math.min(Math.max(0.0, offsetX), maxOffsetX);
    float offsetY = anchorY - gameInfo.getMapHeight() / 2.0;
    float maxOffsetY = gameInfo.getMapHeight() / factor - gameInfo.getMapHeight();
    offsetY = Math.min(Math.max(0.0, offsetY), maxOffsetY);
    coord[0] = x - offsetX;
    coord[1] = y - offsetY;
    coord[2] = w;
    coord[3] = h;
    return coord;
  }
}


public class ErrorPage extends Page {
  private String errMsg;

  public ErrorPage(Page previousPage, String errMsg) {
    super("error", previousPage);
    this.errMsg = errMsg;

    Button backButton = new Button("ButtonBack", 200, 40, "Back", () -> {
      trySwitchPage(getPreviousPage());
    });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
  }

  @Override
  public void drawBackground() { background(PlayPageBackgroundColor); }

  public void draw() { 
    super.draw();
    
    noStroke();
    fill(255);
    textFont(fontErikaType, 20);
    textAlign(CENTER, CENTER);
    text(this.errMsg, gameInfo.getWinWidth() / 2.0, gameInfo.getWinHeight() / 2.0);
  }
}
