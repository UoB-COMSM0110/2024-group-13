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

    // This must be called before adding player widgets.
    // As player widgets need to use control widgets.
    addControlWidgets();

    // `createPlayerWidgets` defined in 'PageModeLocal.pde'
    addLocalItems(createPlayerWidgets(1, 100, 220, () -> { onPlayerNameSet(); }));
    addLocalItems(createPlayerWidgets(2, 500, 220, () -> { onPlayerNameSet(); }));
  }

  private void addControlWidgets() {
    // Create button
    Button createGameButton = new Button("CreateGame", 270, 50, "Create  Game",
        () -> {
          if (gameInfo.isSingleHost()) { startSyncGame(); }
          else { prepareToLeaveGame(); }
    });
    createGameButton.setLeftX(110).setTopY(450);
    addLocalItem(createGameButton);

    // Ip box
    InputBox ipBox = new InputBox("IpBox",
        createGameButton.getW(), createGameButton.getH() - 10, 15, null);
    ipBox.setPromptText("Game Ip Here").setTextAlignHorizon(CENTER).setBoxRadius(10.0)
      .setLeftX(createGameButton.getLeftX() - 20).setTopY(createGameButton.getBottomY() + 40);
    addLocalItem(ipBox);

    // Join button
    Button joinGameButton = new Button("JoinGame", ipBox.getW(), ipBox.getH(), "Join  Game",
        () -> {
          if (gameInfo.isSingleHost()) { startSyncGame(ipBox.getText()); }
          else { prepareToLeaveGame(); }
    });
    joinGameButton.setCenterX(ipBox.getCenterX()).setTopY(ipBox.getBottomY() + 10);
    addLocalItem(joinGameButton);

    // Start button
    Button startButton = new Button("ButtonStart",
        createGameButton.getW(), createGameButton.getH(), "Start  Game",
        () -> { trySwitchPage(new PlayPage(this)); });
    startButton.setLeftX(createGameButton.getRightX() + 40).setTopY(createGameButton.getTopY());
    addLocalItem(startButton);

    // Instruction
    int textSize = 14;
    Label simpleInstruct = new Label("CreateInstruct", 310, textSize * 7,
        "If you're player 1, enter your name,\n" +
        "create game to see your ip,\n" +
        "start game after player 2 joins.\n" +
        "\n" +
        "If you're player 2, enter your name,\n" +
        "enter the ip from player 1,\n" +
        "then join the game.\n");
    simpleInstruct.setTextSize(textSize).setTextAlignVertical(TOP)
      .setLeftX(ipBox.getRightX() + 60).setBottomY(joinGameButton.getBottomY());
    addLocalItem(simpleInstruct);

    // Box
    float boxLeft = min(ipBox.getLeftX(), createGameButton.getLeftX()) - 30;
    float boxRight = max(simpleInstruct.getRightX(), startButton.getRightX()) + 30;
    float boxTop = createGameButton.getTopY() - 20;
    float boxBottom = joinGameButton.getBottomY() + 20;
    RectArea controlBox = new RectArea("ControlBox", boxRight - boxLeft, boxBottom - boxTop);
    controlBox.setDrawBox(true).setBoxFillColor(color(205, 147, 102))
      .setBoxStrokeWeight(3).setBoxStrokeColor(color(96, 32, 32)).setBoxRadius(10)
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
    Button createGameButton = (Button)getLocalItem("CreateGame");
    Button joinGameButton = (Button)getLocalItem("JoinGame");
    InputBox ipBox = (InputBox)getLocalItem("IpBox");
    InputBox playerName1 = (InputBox)getLocalItem("InputBoxPlayerName1");
    InputBox playerName2 = (InputBox)getLocalItem("InputBoxPlayerName2");
    if (gameInfo.isServerHost()) {
      createGameButton.enable().setText("Leave Game");
      joinGameButton.disable().setText("Join Game");
      ipBox.disable().setPrefix("Ip: ").setText(getIpAddr());
      playerName1.enable();
      playerName2.disable().setText("");
    } else if (gameInfo.isClientHost()) {
      createGameButton.disable().setText("Create Game");
      joinGameButton.enable().setText("Leave Game");
      ipBox.disable().setPrefix("");
      playerName1.disable().setText("");
      playerName2.enable();
    } else {
      createGameButton.enable().setText("Create Game");
      joinGameButton.enable().setText("Join Game");
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
