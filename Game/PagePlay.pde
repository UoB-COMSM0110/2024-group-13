final String mapPath = "data/map.csv";
final int PlayPageBackgroundColor = color(155, 82, 52);

final int textSizeBoard = 17;
final int textScore = 45;
final int textEvent = 17;
final int textBullet = 15;
final int textLabels = 12;

public class PlayPage extends Page {
  private JSONArray syncDeletesRecord;

  public PlayPage(Page previousPage) {
    super("play", previousPage);
    this.syncDeletesRecord = new JSONArray();

    // Draw out a special area for showing local widgets.
    RectArea localArea = new RectArea("LocalArea",
        gameInfo.getWinWidth(), gameInfo.getMapOffsetY());
    localArea.setDrawBox(true)
      .setBoxStrokeWeight(3.0)
      .setBoxStrokeColor(color(66, 33, 11))
      .setBoxFillColor(PlayPageBackgroundColor)
      .setLayer(-9);
    addLocalItem(localArea);

    // Quit the game before it ends.
    Button backButton = new Button("ButtonBack", 35, 35, "X",
        () -> { trySwitchPage(getPreviousPage()); });
    backButton.setX(10).setY(5);
    addLocalItem(backButton);

    createPlayerStatusWidgets(1, 50, 8);
    createPlayerStatusWidgets(2, 425, 8);

    Label gameOverLabel = new Label("LabelGameOver", 500, 100, "Game  Over");
    gameOverLabel.setTextAlignHorizon(CENTER).setTextFont(fontMinecraft).setTextSize(80)
      .setDrawBox(true).setBoxFillColor(color(255, 253, 208))
      .setCenterX(gameInfo.getWinWidth() / 2).setCenterY(gameInfo.getWinHeight() / 2).discard();
    addLocalItem(gameOverLabel);

    // Load the map, i.e., all the synchronised items.
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
    GameState gameState = (GameState)getSyncItem("GameState");
    gameState.step();
    if (!gameState.isGameOver()) {
      super.doEvolve(events);
    } else if (gameState.isGameFinished()) {
      goToGameOverPage();
    }
  }

  @Override
  public void solveCollisions() {
    GameState gameState = (GameState)getSyncItem("GameState");
    (new CollisionEngine()).solveCollisions(() -> gameState.isGameOver());
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
        if (otherPlayerPage.equals("onlinemode")) { return true; }
        onNetworkFailure("client is not playing");
        return false;
      }
    }
    if (json.getString("nextPage").equals("onlinemode")) {
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
    float verticalSpace = 14;
    float lineHeight = 15;

    if (playerId == 1) {
      // Player name
      String player1NameText = gameInfo.getPlayerName1();
      Label playerName1 = new Label("PlayerName1", 180, lineHeight, player1NameText);
      playerName1.setTextSize(textSizeBoard).setLeftX(xOffset + 223).setY(84).setLayer(6);
      playerName1.setTextFont(fontSFBold);
      addLocalItem(playerName1); 
      
      // Name Prompt
      Label namePrompt = new Label("NamePrompt" + playerId, 80, lineHeight, "Name");
      namePrompt.setTextFont(fontSFBold).setTextSize(textLabels)
        .setLeftX(playerName1.getLeftX()).setBottomY(playerName1.getTopY() - 8).setLayer(4);
      addLocalItem(namePrompt);

      // Background box
      PImage player1Box = loadImage("data/player1Labels.png");
      RectArea box = new RectArea("InstructionKeyset" + playerId, 353, 103);
      box.setImage(player1Box)
        .setLeftX(xOffset).setTopY(yOffset).setLayer(1);
      addLocalItem(box);
      
      // Score
      Label score = new Label("Score" + playerId, 150, lineHeight, "0");
      score.setTextSize(textScore).setLeftX(xOffset+5).setY(70).setLayer(6);
      score.setTextFont(fontMinecraft);  
      addLocalItem(score);
      
      // Score Prompt
      Label scorePrompt = new Label("ScorePrompt" + playerId, 80, lineHeight, "Score");
      scorePrompt.setTextFont(fontSFBold).setTextSize(15)
        .setLeftX(score.getLeftX()).setBottomY(score.getTopY() - verticalSpace).setLayer(4);
      addLocalItem(scorePrompt);
      
      // Lives
      for (int i = 1; i <= 3; ++i) {
        float x = (xOffset + 30) + lineHeight * (i - 1) + 3;
        RectArea heart = new RectArea("Heart_" + playerId + "_" + i, lineHeight, lineHeight);
        heart.setImage(imageHeart3).setLeftX(x).setCenterY(24).setLayer(5);
        addLocalItem(heart);
      }    
      
      // Number of bullets
      Label bulletNumber = new Label("BulletNumber" + playerId, 25, lineHeight, "0");
      bulletNumber.setTextSize(textBullet)
        .setLeftX(xOffset + 200).setCenterY(21).setLayer(5);
      addLocalItem(bulletNumber);
      
      // Bullets Prompt
      Label bulletsPrompt = new Label("ExplosivesPrompt" + playerId, 80, lineHeight, "Explosives");
      bulletsPrompt.setTextFont(fontSFBold).setTextSize(textLabels)
        .setRightX(bulletNumber.getLeftX() + 17).setCenterY(bulletNumber.getCenterY()).setLayer(4);
      addLocalItem(bulletsPrompt);
      
      // Current PowerUp
      Label buffDesc = new Label("BuffDesc" + playerId, 200, lineHeight, "");
      buffDesc.setTextSize(textEvent).setLeftX(xOffset + 223).setY(38).setLayer(6);
      addLocalItem(buffDesc);
      
      // PowerUp Prompt
      Label buffPrompt = new Label("BuffPrompt" + playerId, 80, lineHeight, "Special Event");
      buffPrompt.setTextFont(fontSFBold).setTextSize(textLabels)
        .setLeftX(buffDesc.getLeftX()).setCenterY(bulletNumber.getCenterY()).setLayer(4);
      addLocalItem(buffPrompt);
    }
    
    if (playerId == 2) {
      // Player name
      String player2NameText = gameInfo.getPlayerName2();
      Label playerName2 = new Label("PlayerName2", 180, lineHeight, player2NameText);
      playerName2.setTextSize(textSizeBoard).setLeftX(xOffset + 223).setY(84).setLayer(6);
      playerName2.setTextFont(fontSFBold).setTextColor(color(224, 223, 224));
      addLocalItem(playerName2); 
      
      // Name Prompt
      Label namePrompt = new Label("NamePrompt" + playerId, 80, lineHeight, "Name");
      namePrompt.setTextFont(fontSFBold).setTextSize(textLabels).setTextColor(color(224, 223, 224))
        .setLeftX(playerName2.getLeftX()).setBottomY(playerName2.getTopY() - 8).setLayer(4);
      addLocalItem(namePrompt);
      
      // Background box
      PImage player1Box = loadImage("data/player2Labels.png");
      RectArea box = new RectArea("InstructionKeyset" + playerId, 353, 103);
      box.setImage(player1Box)
        .setLeftX(xOffset).setTopY(yOffset).setLayer(1);
      addLocalItem(box);
            
      // Score
      Label score = new Label("Score" + playerId, 150, lineHeight, "0");
      score.setTextSize(textScore).setLeftX(xOffset+5).setY(70).setLayer(6);
      score.setTextFont(fontMinecraft).setTextColor(color(224, 223, 224));  
      addLocalItem(score);
      
      // Score Prompt
      Label scorePrompt = new Label("ScorePrompt" + playerId, 80, lineHeight, "Score");
      scorePrompt.setTextFont(fontSFBold).setTextSize(15).setTextColor(color(224, 223, 224))
        .setLeftX(score.getLeftX()).setBottomY(score.getTopY() - verticalSpace).setLayer(4);
      addLocalItem(scorePrompt);
      
      // Lives
      for (int i = 1; i <= 3; ++i) {
        float x = (xOffset + 30) + lineHeight * (i - 1) + 3;
        RectArea heart = new RectArea("Heart_" + playerId + "_" + i, lineHeight, lineHeight);
        heart.setImage(imageHeart3).setLeftX(x).setCenterY(24).setLayer(5);
        addLocalItem(heart);
      }
      
      // Number of bullets
      Label bulletNumber2 = new Label("BulletNumber" + playerId, 25, lineHeight, "0");
      bulletNumber2.setTextSize(textBullet).setLeftX(xOffset + 200).setCenterY(21).setLayer(5);
      addLocalItem(bulletNumber2);

      // Bullets Prompt
      Label bulletsPrompt = new Label("ExplosivesPrompt" + playerId, 80, lineHeight, "Explosives");
      bulletsPrompt.setTextFont(fontSFBold).setTextSize(textLabels).setTextColor(color(224, 223, 224))
        .setRightX(bulletNumber2.getLeftX() + 17).setCenterY(bulletNumber2.getCenterY()).setLayer(4);
      addLocalItem(bulletsPrompt);
      
      // Current PowerUp
      Label buffDesc = new Label("BuffDesc" + playerId, 200, lineHeight, "");
      buffDesc.setTextSize(textEvent).setLeftX(xOffset + 223).setY(38).setLayer(6);
      addLocalItem(buffDesc);      

      // PowerUp Prompt
      Label buffPrompt = new Label("BuffPrompt" + playerId, 80, lineHeight, "Special Event");
      buffPrompt.setTextFont(fontSFBold).setTextSize(textLabels).setTextColor(color(224, 223, 224))
        .setLeftX(buffDesc.getLeftX()).setCenterY(bulletNumber2.getCenterY()).setLayer(4);
      addLocalItem(buffPrompt);
    }
    
    // // For debug use:
    // playerPrompt.setDrawBox(true);
    // playerName.setDrawBox(true);
    // score.setDrawBox(true);
    // bulletNumber.setDrawBox(true);
    // buffDesc.setDrawBox(true);
    // keyset.setDrawBox(true);
  }

  private void loadMap(String mapPath) {
    generateMapBorders();
    addSyncItem(new ViewShader());
    addSyncItem(new GameState());

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
    float borderSize = CHARACTER_SIZE * 20.0;
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

  // Place pacman at the center, and zoom the map according to view factor.
  public float[] getFactoredCoord(float x, float y, float w, float h) {
    float[] coord = new float[4];
    float factor = 1.0;
    float anchorX = gameInfo.getMapWidth() / 2.0;
    float anchorY = gameInfo.getMapHeight() / 2.0;
    if (!gameInfo.isSingleHost()) {
      int playerId = gameInfo.isServerHost() ? 1 : 2;
      Pacman pacman = getPacman(playerId);
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
  
  @Override
  public void onSwitchOut() {
    backgroundMusicPlayer.unmute();
  }
}


// This page shows up when network problems emerge during playing.
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
