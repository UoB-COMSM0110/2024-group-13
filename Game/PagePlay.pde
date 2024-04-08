void loadResourcesForPlayPage() {
}


final String mapPath = "data/map.csv";
final int PlayPageBackgroundColor = color(155, 82, 52);

public class PlayPage extends Page {
  private JSONArray syncDeletesRecord;
  private ArrayList<PowerUp> powerups = new ArrayList<>();
  private boolean isGameOver;
  
  public PlayPage(Page previousPage) {
    super("play", previousPage);
    this.syncDeletesRecord = new JSONArray();

    RectArea localArea = new RectArea("LocalArea",
        gameInfo.getWinWidth(), gameInfo.getMapOffsetY());
    localArea.setDrawBox(true)
      .setBoxStrokeWeight(5.0)
      .setBoxStrokeColor(color(102, 51, 0))
      .setBoxFillColor(PlayPageBackgroundColor)
      .setLayer(-9);
    addLocalItem(localArea);

    Button backButton = new Button("ButtonBack", 120, 35, "End Game",
        () -> { trySwitchPage(getPreviousPage()); });
    backButton.setX(10).setY(5);
    addLocalItem(backButton);

    Label fps = new Label("Fps", backButton.getW(), backButton.getH(), "");
    fps.setPrefix("fps:").setX(backButton.getX()).setTopY(backButton.getBottomY());
    addLocalItem(fps);
    addTimer(new Timer(0.0, 1.0,
          () -> { fps.setText(String.format("%.2f", frameRate)); }));

    // Player 1 status
    Label score1 = new Label("Score1", 120, 25, "0");
    score1.setX(350).setY(10);
    addLocalItem(score1);
    Label playerName1 = new Label("PlayerName1",
        120, score1.getH(), gameInfo.getPlayerName1());
    playerName1.setTextAlignHorizon(RIGHT).setRightX(score1.getLeftX()).setY(score1.getY());
    addLocalItem(playerName1);
    Label lives1 = new Label("Lives1", 20, score1.getH(), "0");
    lives1.setLeftX(score1.getRightX()).setY(score1.getY());
    addLocalItem(lives1);

    int offset = 30;
    // Player 2 status
    Label score2 = new Label("Score2", score1.getW(), score1.getH(), "0");
    score2.setX(score1.getX()).setY(score1.getY() + offset);
    addLocalItem(score2);
    Label playerName2 = new Label("PlayerName2",
        playerName1.getW(), score2.getH(), gameInfo.getPlayerName2());
    playerName2.setTextAlignHorizon(RIGHT).setRightX(score2.getLeftX()).setY(score2.getY());
    addLocalItem(playerName2);
    Label lives2 = new Label("Lives2", lives1.getW(), score2.getH(), "0");
    lives2.setLeftX(score2.getRightX()).setY(score2.getY());
    addLocalItem(lives2);
    
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
    }
  }

  @Override
  public void solveCollisions() {
    (new CollisionEngine()).solveCollisions(() -> isGameOver());
  }

  public boolean isGameOver() { return this.isGameOver; }
  public void gameOver() {
    this.isGameOver = true;
    Pacman pacman1 = (Pacman)getSyncItem(itemTypePacman + "1");
    Pacman pacman2 = (Pacman)getSyncItem(itemTypePacman + "2");
    trySwitchPage(new GameOverPage(pacman1.getScore(), pacman2.getScore(), getPreviousPage()));
  }

  @Override
  public void dispatchSyncInfo(JSONObject json) {
    super.dispatchSyncInfo(json);
    if (gameInfo.isClientHost()) {
      gameInfo.setPlayerName2(json.getString("player2"));
    }
  }

  @Override
  public void onNetworkFailure(String where, Exception e) {
    String errMsg = where + e.toString();
    trySwitchPage(new ErrorPage(getPreviousPage(), errMsg));
  }

  @Override
  public void drawBackground() { background(PlayPageBackgroundColor); }

  private void loadMap(String mapPath) {
    generateMapBorders();

    // generate powerups
    powerups.add(new OpponentControlPowerUp(CHARACTER_SIZE, CHARACTER_SIZE));
    powerups.add(new SizeModificationPowerUp_Ghost(CHARACTER_SIZE, CHARACTER_SIZE));
    powerups.add(new SizeModificationPowerUp_Pacman(CHARACTER_SIZE, CHARACTER_SIZE));
    powerups.add(new TimeFreezePowerUp(CHARACTER_SIZE, CHARACTER_SIZE));
    powerups.add(new TeleportPowerUp(CHARACTER_SIZE, CHARACTER_SIZE));
    powerups.add(new TrapPowerUp(CHARACTER_SIZE, CHARACTER_SIZE));
    powerups.add(new GhostMagnetPowerUp(CHARACTER_SIZE, CHARACTER_SIZE));
    powerups.add(new SpeedSurgePowerUp(CHARACTER_SIZE, CHARACTER_SIZE));
    

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
          generatePowerUp(x, y);
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
    float borderSize = 5.0;
    float verticalBorderHeight = 2.0 * borderSize + gameInfo.getMapHeight();
    float horizonBorderWidth = 2.0 * borderSize + gameInfo.getMapWidth();
    Border leftBorder = new Border("LeftBorder", borderSize, verticalBorderHeight);
    leftBorder.setX(-borderSize).setY(-borderSize);
    addSyncItem(leftBorder);
    Border rightBorder = new Border("RightBorder", borderSize, verticalBorderHeight);
    rightBorder.setX(gameInfo.getMapWidth()).setY(-borderSize);
    addSyncItem(rightBorder);
    Border topBorder = new Border("TopBorder", horizonBorderWidth, borderSize);
    topBorder.setX(-borderSize).setY(-borderSize);
    addSyncItem(topBorder);
    Border bottomBorder = new Border("BottomBorder", horizonBorderWidth, borderSize);
    bottomBorder.setX(-borderSize).setY(gameInfo.getMapHeight());
    addSyncItem(bottomBorder);
  }
  
  private void generatePowerUp(float x, float y) {
    PowerUp selectedPowerUp = null;
    while (selectedPowerUp == null) {
      int index = (int) random(powerups.size());
      PowerUp powerup = powerups.get(index);
      if (powerup.getInUse()) {
        continue;
      } else {
        powerup.setInUse(true);
        selectedPowerUp = powerup;
      }
    }
          
    selectedPowerUp.setX(x).setY(y);
    addSyncItem(selectedPowerUp);
  }
}


public class ErrorPage extends Page {
  private String errMsg;

  public ErrorPage(Page previousPage, String errMsg) {
    super("error", previousPage);
    this.errMsg = errMsg;

    Button backButton = new Button("ButtonBack", 200, 40, "Back", () -> {
      switchPage(getPreviousPage());
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
    textSize(25);
    text(this.errMsg, 300, 110);
  }
}
