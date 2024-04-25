// The page for starting an online game.
public class OnlineModePage extends Page {
  private boolean leavingGame;
  private String otherPlayerPage;

  public OnlineModePage(Page previousPage) {
    super("onlinemode", previousPage);
    this.leavingGame = false;
    this.otherPlayerPage = "";

    Button backButton = new Button("ButtonBack", 200, 40, "Back", () -> {
        prepareToLeaveGame();
        trySwitchPage(getPreviousPage());
    });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);

    // `createPlayerWidgets` defined in 'PageModeLocal.pde'
    addLocalItems(createPlayerWidgets(1, 100, 220, () -> { onPlayerNameSet(); }));
    addLocalItems(createPlayerWidgets(2, 500, 220, () -> { onPlayerNameSet(); }));

    addControlWidgets1(280, 50, 205, 447);
    addControlWidgets2(280, 50, 605, 447);
  }

  private void addControlWidgets1(float buttonW, float buttonH, float xOffset, float yOffset) {
    // Create button
    Button createButton = new Button("CreateGame", buttonW, buttonH, "Create  Game", () -> {
          if (gameInfo.isSingleHost()) { startSyncGame(); }
          else { prepareToLeaveGame(); }
    });
    createButton.setCenterX(xOffset).setCenterY(yOffset);
    addLocalItem(createButton);

    // Start button
    Button startButton = new Button("ButtonStart", buttonW, buttonH, "Start  Game",
        () -> { trySwitchPage(new PlayPage(this)); });
    startButton.setCenterX(createButton.getCenterX()).setCenterY(createButton.getCenterY() + 60);
    addLocalItem(startButton);

    // Instruction
    int textSize = 14;
    Label simpleInstruct = new Label("CreateInstruct", 280, textSize * 4,
        "To play as player 1,\n" +
        "enter your name,\n" +
        "create game to see your game ip,\n" +
        "start game after player 2 joins.");
    simpleInstruct.setTextSize(textSize).setTextAlignVertical(TOP)
      .setLeftX(startButton.getLeftX()).setTopY(startButton.getBottomY() + 30);
    addLocalItem(simpleInstruct);

    // Box
    float boxLeft = createButton.getLeftX() - 20;
    float boxRight = createButton.getRightX() + 20;
    float boxTop = createButton.getCenterY() - 45;
    float boxBottom = simpleInstruct.getBottomY() + 20;
    RectArea controlBox = new RectArea("CreateControlBox", boxRight - boxLeft, boxBottom - boxTop);
    controlBox.setDrawBox(true).setBoxFillColor(color(205, 147, 102))
      .setBoxStrokeWeight(3).setBoxStrokeColor(color(96, 32, 32)).setBoxRadius(5)
      .setLayer(-1).setLeftX(boxLeft).setTopY(boxTop);
    addLocalItem(controlBox);

    // // For debug:
    // simpleInstruct.setDrawBox(true);
  }

  private void addControlWidgets2(float buttonW, float buttonH, float xOffset, float yOffset) {
    // Ip box
    InputBox ipBox = new InputBox("IpBox", buttonW - 5, buttonH - 15, 15, null);
    ipBox.setPromptText("Game Ip Here").setTextAlignHorizon(CENTER).setBoxRadius(8)
      .setCenterX(xOffset).setCenterY(yOffset);
    addLocalItem(ipBox);

    // Join button
    Button joinButton = new Button("JoinGame", buttonW, buttonH, "Join  Game", () -> {
        if (gameInfo.isSingleHost()) { startSyncGame(ipBox.getText()); }
        else { prepareToLeaveGame(); }
    });
    joinButton.setCenterX(ipBox.getCenterX()).setCenterY(ipBox.getCenterY() + 60);
    addLocalItem(joinButton);

    // Instruction
    int textSize = 14;
    Label simpleInstruct = new Label("JoinInstruct", 280, textSize * 4,
        "To play as player 2,\n" +
        "enter your name,\n" +
        "enter the game ip from player 1,\n" +
        "then join the game.");
    simpleInstruct.setTextSize(textSize).setTextAlignVertical(TOP)
      .setLeftX(joinButton.getLeftX()).setTopY(joinButton.getBottomY() + 30);
    addLocalItem(simpleInstruct);

    // Box
    float boxLeft = ipBox.getLeftX() - 20;
    float boxRight = ipBox.getRightX() + 20;
    float boxTop = ipBox.getCenterY() - 45;
    float boxBottom = simpleInstruct.getBottomY() + 20;
    RectArea controlBox = new RectArea("JoinControlBox", boxRight - boxLeft, boxBottom - boxTop);
    controlBox.setDrawBox(true).setBoxFillColor(color(205, 147, 102))
      .setBoxStrokeWeight(3).setBoxStrokeColor(color(96, 32, 32)).setBoxRadius(5)
      .setLayer(-1).setLeftX(boxLeft).setTopY(boxTop);
    addLocalItem(controlBox);

    // // For debug:
    // simpleInstruct.setDrawBox(true);
  }

  void startSyncGame() {
    if (gameInfo.startSyncAsServer()) {
      updateWidgets();
    }
  }
  void startSyncGame(String serverIp) {
    if (serverIp == null || serverIp.isEmpty()) { return; }
    if (gameInfo.startSyncAsClient(serverIp)) {
      updateWidgets();
    }
  }
  void prepareToLeaveGame() {
    this.leavingGame = true;
    if (isSwitchingTo("play")) { stopSwitchingPage(); }
    updateStartButton();
  }

  @Override
  public boolean isLeavingGame() { return this.leavingGame; }

  @Override
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) { return false; }
    if (!this.otherPlayerPage.equals(json.getString("page"))) {
      this.otherPlayerPage = json.getString("page");
      updateStartButton();
    }
    if (!json.getString("page").equals(getName())) { return true; }
    if (gameInfo.isServerHost() && !isSwitchingTo("play")) {
      gameInfo.setPlayerName2(json.getString("player2"));
      onPlayerNameSet();
    }
    if (gameInfo.isClientHost()) {
      gameInfo.setPlayerName1(json.getString("player1"));
      onPlayerNameSet();
      if (json.getString("nextPage").equals("play")) {
        trySwitchPage(new PlayPage(this));
      }
    }
    return true;
  }

  @Override
  public void update() {
    super.update();
    if (isLeavingGame()) {
      leaveGame();
    }
  }

  public void leaveGame() {
    this.leavingGame = false;
    if (gameInfo.isServerHost()) { gameInfo.writeOutSocketServer(2000); }
    if (gameInfo.isClientHost()) { gameInfo.writeOutSocketClient(2000); }
    gameInfo.stopSync();
  }

  public void onPlayerNameSet() { updateStartButton(); }

  @Override
  public void onConnectionStart() {
    super.onConnectionStart();
    updateStartButton();
  }

  @Override
  public void onConnectionClose() {
    super.onConnectionClose();
    this.otherPlayerPage = "";
    if (isSwitchingTo("play")) { stopSwitchingPage(); }
    updateWidgets();
  }

  @Override
  public void onSwitchIn() {
    super.onSwitchIn();
    this.otherPlayerPage = "";
    updateWidgets();
  }

  public void updateWidgets() {
    Button createButton = (Button)getLocalItem("CreateGame");
    Button joinButton = (Button)getLocalItem("JoinGame");
    InputBox ipBox = (InputBox)getLocalItem("IpBox");
    InputBox playerName1 = (InputBox)getLocalItem("InputBoxPlayerName1");
    InputBox playerName2 = (InputBox)getLocalItem("InputBoxPlayerName2");
    if (gameInfo.isServerHost()) {
      createButton.enable().setText("Leave Game");
      joinButton.disable().setText("Join Game");
      ipBox.disable().setPrefix("Ip: ").setText(getIpAddr());
      playerName1.enable();
      playerName2.disable().setText("");
    } else if (gameInfo.isClientHost()) {
      createButton.disable().setText("Create Game");
      joinButton.enable().setText("Leave Game");
      ipBox.disable().setPrefix("");
      playerName1.disable().setText("");
      playerName2.enable();
    } else {
      createButton.enable().setText("Create Game");
      joinButton.enable().setText("Join Game");
      ipBox.enable().setPrefix("");
      if (ipBox.getText().equals(getIpAddr())) { ipBox.setText(""); }
      playerName1.enable();
      playerName2.enable();
    }
    updateStartButton();
  }

  public void updateStartButton() {
    Button startButton = (Button)getLocalItem("ButtonStart");
    boolean enable = gameInfo.isServerHost();
    enable = enable && gameInfo.getPlayerName1().length() > 0;
    enable = enable && gameInfo.getPlayerName2().length() > 0;
    enable = enable && gameInfo.isConnected();
    enable = enable && !isLeavingGame();
    enable = enable && this.otherPlayerPage.equals("onlinemode");
    if (enable) { startButton.enable(); }
    else { startButton.disable(); }
  }
  
  @Override
  public void drawBackground() {
      float winWidth = gameInfo.getWinWidth();
      float winHeight = gameInfo.getWinHeight();
      image(imageStartPageBackground, 0, 0, winWidth, winHeight);
      drawTextWithOutline("Online  Game", gameInfo.getWinWidth() / 2, 130, 80, 3, color(255));
  }
}
