void loadResourcesForPlayPage() {}

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

    // Player 1 status
    Label playerPrompt1 = new Label("PlayerPrompt1",
        112.5, 26.25, "Player : ");
    playerPrompt1.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(250).setY(4);
    addLocalItem(playerPrompt1);
    
    Label scorePrompt1 = new Label("ScorePrompt1",
        112.5, 26.25, "Score : ");
    scorePrompt1.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(250).setY(20);
    addLocalItem(scorePrompt1);
    
    Label livesPrompt1 = new Label("LivesPrompt1",
        112.5, 26.25, "Lives : ");
    livesPrompt1.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(250).setY(36);
    addLocalItem(livesPrompt1);
    
    Label powerupPrompt1 = new Label("PowerupPrompt1",
        112.5, 26.25, "PowerUp : ");
    powerupPrompt1.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(250).setY(52);
    addLocalItem(powerupPrompt1);
    
    Label score1 = new Label("Score1", 120, 25, "0");
    score1.setTextSize(textSizeBoard).setX(250).setY(20);
    addLocalItem(score1);
    
    Label playerName1 = new Label("PlayerName1",
        120, score1.getH(), gameInfo.getPlayerName1());
    playerName1.setTextAlignHorizon(LEFT).setTextSize(textSizeBoard).setRightX(370).setY(4);
    addLocalItem(playerName1);

    Label lives1 = new Label("Lives1", 20, score1.getH(), "0");
    lives1.setTextSize(textSizeBoard).setLeftX(250).setY(36);
    addLocalItem(lives1);
    
    Label powerupDesc1 = new Label("PowerupDesc1", 120, score1.getH(), "");
    powerupDesc1.setTextSize(textSizeBoard).setLeftX(250).setY(52);
    addLocalItem(powerupDesc1);

    // Player 2 status
    Label playerPrompt2 = new Label("PlayerPrompt2",
        112.5, 26.25, "Player : ");
    playerPrompt2.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(570).setY(playerPrompt1.getY());
    addLocalItem(playerPrompt2);
    
    Label scorePrompt2 = new Label("ScorePrompt2",
        112.5, 26.25, "Score : ");
    scorePrompt2.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(570).setY(scorePrompt1.getY());
    addLocalItem(scorePrompt2);
    
    Label livesPrompt2 = new Label("LivesPrompt2",
        112.5, 26.25, "Lives : ");
    livesPrompt2.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(570).setY(livesPrompt1.getY());
    addLocalItem(livesPrompt2);
    
    Label powerupPrompt2 = new Label("PowerupPrompt2",
        112.5, 26.25, "PowerUp : ");
    powerupPrompt2.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft).setTextSize(textSizeBoard)
      .setRightX(570).setY(powerupPrompt1.getY());
    addLocalItem(powerupPrompt2);
    
    Label score2 = new Label("Score2", score1.getW(), score1.getH(), "0");
    score2.setTextSize(textSizeBoard).setX(570).setY(score1.getY());
    addLocalItem(score2);
    
    Label playerName2 = new Label("PlayerName2",
        playerName1.getW(), score2.getH(), gameInfo.getPlayerName2());
    playerName2.setTextSize(textSizeBoard).setTextAlignHorizon(LEFT).setRightX(690).setY(playerName1.getY());
    addLocalItem(playerName2);
    
    Label lives2 = new Label("Lives2", lives1.getW(), score2.getH(), "0");
    lives2.setTextSize(textSizeBoard).setLeftX(570).setY(lives1.getY());
    addLocalItem(lives2);
    
    Label powerupDesc2 = new Label("PowerupDesc2", powerupDesc1.getW(), powerupDesc1.getH(), "");
    powerupDesc2.setTextSize(textSizeBoard).setLeftX(570).setY(powerupDesc1.getY());
    addLocalItem(powerupDesc2);
    
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
