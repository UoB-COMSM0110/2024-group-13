final String imagePathStartPageBackground = "data/StartPageBackground.png";
PImage imageStartPageBackground;
final String imagePathGameBanner = "data/GameBanner.png";
PImage imageGameBanner;


// The first page of the game.
public class StartPage extends Page {
  public StartPage(Page previousPage) {
    super("start", previousPage);
    imageStartPageBackground = loadImage(imagePathStartPageBackground);
    imageGameBanner = loadImage(imagePathGameBanner);

    // Start button
    Button startButton = new Button("ButtonStart", 200, 50, "Start",
        () -> { trySwitchPage(new PlayPage(this)); });
    startButton.setUpdater(() -> {
        boolean enable = !gameInfo.isClientHost();
        enable = enable && gameInfo.getPlayerName1().length() > 0;
        enable = enable && gameInfo.getPlayerName2().length() > 0;
        if (gameInfo.isServerHost()) {
          enable = enable && gameInfo.isConnectedToClient();
        }
        if (enable) { startButton.enable(); }
        else { startButton.disable(); }
    });
    startButton.disable().setCenterX(gameInfo.getWinWidth() / 2.0).setY(500);
    addLocalItem(startButton);
    // Help button
    Button helpButton = new Button("ButtonHelp", startButton.getW(), startButton.getH(), "Help",
        () -> { trySwitchPage(new HelpPage(this)); });
    helpButton.setX(startButton.getX()).setTopY(startButton.getBottomY() + 20);
    addLocalItem(helpButton);

    // Player name 1
    Label playerNamePrompt1 = new Label("PlayerNamePrompt1",
        150, 35, "Player 1 : ");
    playerNamePrompt1.setTextAlignHorizon(RIGHT).setTextFont(fontMinecraft)
      .setRightX(170).setY(330);
    addLocalItem(playerNamePrompt1);
    InputBox playerName1 = new InputBox("InputBoxPlayerName1",
        210, playerNamePrompt1.getH(), 15, (bx, oStr, nStr) -> {
        gameInfo.setPlayerName1(nStr);
        if (nStr.length() <= 0) { startButton.disable(); }
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
        if (nStr.length() <= 0) { startButton.disable(); }
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
          if (!gameInfo.isServerHost()) { gameInfo.startSyncAsServer(); }
          else { gameInfo.stopSyncAsServer(); }
    });
    createGameButton.setX(ipBox.getX()).setBottomY(ipBox.getTopY() - 10);
    addLocalItem(createGameButton);
    // Join button
    Button joinGameButton = new Button("JoinGame", ipBox.getW(), ipBox.getH(), "Join Game",
        () -> {
          if (!gameInfo.isClientHost()) { gameInfo.startSyncAsClient(ipBox.getText()); }
          else { gameInfo.stopSyncAsClient(); }
    });
    joinGameButton.setX(ipBox.getX()).setTopY(ipBox.getBottomY() + 10);
    addLocalItem(joinGameButton);
  }

  @Override
  public void dispatchSyncInfo(JSONObject json) {
    // TODO: illegal player name after server start button clicked;
    super.dispatchSyncInfo(json);
    // TODO: connection close after server start button clicked;

    if (gameInfo.isClientHost() && json.getString("nextPage").equals("play")) {
      trySwitchPage(new PlayPage(this));
    }
  }

  @Override
  public void onSwitchIn() {
    super.onSwitchIn();
    adjustWidgets();
  }

  @Override
  public void onSyncStart() {
    super.onSyncStart();
    adjustWidgets();
  }

  @Override
  public void onConnectionClose() {
    super.onConnectionClose();
    adjustWidgets();
  }

  public void adjustWidgets() {
    Button createGameButton = (Button)getLocalItem("CreateGame");
    Button joinGameButton = (Button)getLocalItem("JoinGame");
    Button startButton = (Button)getLocalItem("ButtonStart");
    InputBox ipBox = (InputBox)getLocalItem("IpBox");
    InputBox playerName1 = (InputBox)getLocalItem("InputBoxPlayerName1");
    InputBox playerName2 = (InputBox)getLocalItem("InputBoxPlayerName2");
    if (gameInfo.isServerHost()) {
      createGameButton.enable().setText("Leave Game");
      joinGameButton.disable().setText("Join Game");
      startButton.disable().setText("Start Online");
      ipBox.disable().setPrefix("Ip: ").setText(getIpAddr());
      playerName1.enable();
      playerName2.disable().setText("");
    } else if (gameInfo.isClientHost()) {
      createGameButton.disable().setText("Create Game");
      joinGameButton.enable().setText("Leave Game");
      ipBox.disable().setPrefix("");
      startButton.disable().setText("Start");
      playerName1.disable().setText("");
      playerName2.enable();
    } else {
      createGameButton.enable().setText("Create Game");
      joinGameButton.enable().setText("Join Game");
      ipBox.enable().setPrefix("");
      if (ipBox.getText().equals(getIpAddr())) { ipBox.setText(""); }
      startButton.disable().setText("Start");
      playerName1.enable();
      playerName2.enable();
    }
  }

  @Override
  public void drawBackground() {
    float winWidth = gameInfo.getWinWidth();
    float winHeight = gameInfo.getWinHeight();
    image(imageStartPageBackground, 0, 0, winWidth, winHeight);
    float bannerWidth = 510;
    image(imageGameBanner, (winWidth - bannerWidth) / 2, 130, bannerWidth, 165);
  }
}
