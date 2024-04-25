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

    // Start button
    Button startButton = new Button("ButtonStart", 200, 50, "Start",
        () -> { trySwitchPage(new PlayPage(this)); });
    startButton.setCenterX(gameInfo.getWinWidth() / 2.0).setY(600);
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

    // Ip box
    InputBox ipBox = new InputBox("IpBox", 270, 40, 15, (bx, oStr, nStr) -> {});
    ipBox.setPromptText("Enter Game Ip Here").setTextAlignHorizon(CENTER).setBoxRadius(10.0)
      .setX(500).setTopY(360);
    addLocalItem(ipBox);
    // Create button
    Button createGameButton = new Button("CreateGame", ipBox.getW(), ipBox.getH(), "Create Game",
        () -> {
          if (gameInfo.isSingleHost()) { startSyncGame(); }
          else { prepareToLeaveGame(); }
    });
    createGameButton.setX(ipBox.getX()).setBottomY(ipBox.getTopY() - 10);
    addLocalItem(createGameButton);
    // Join button
    Button joinGameButton = new Button("JoinGame", ipBox.getW(), ipBox.getH(), "Join Game",
        () -> {
          if (gameInfo.isSingleHost()) { startSyncGame(ipBox.getText()); }
          else { prepareToLeaveGame(); }
    });
    joinGameButton.setX(ipBox.getX()).setTopY(ipBox.getBottomY() + 10);
    addLocalItem(joinGameButton);
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
      drawTextWithOutline("Online  Game", 400, 220, 80, 3, color(255));
  }
}
