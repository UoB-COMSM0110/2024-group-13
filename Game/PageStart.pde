final String imagePathStartPageBackground = "data/StartPageBackground.png";
PImage imageStartPageBackground;
final String imagePathGameBanner = "data/GameBanner.png";


// The first page of the game.
public class StartPage extends Page {
  private PImage imageGameBanner;

  public StartPage(Page previousPage) {
    super("start", previousPage);
    imageStartPageBackground = loadImage(imagePathStartPageBackground);
    this.imageGameBanner = loadImage(imagePathGameBanner);

    Button playButton = new Button("ButtonPlay", 200, 40, "Start", () -> {
        trySwitchPage(new PlayPage(this));
    });
    playButton.setUpdater(() -> {
        boolean enable = !gameInfo.isClientHost();
        enable = enable && gameInfo.getPlayerName1().length() > 0;
        enable = enable && gameInfo.getPlayerName2().length() > 0;
        if (gameInfo.isServerHost()) {
          enable = enable && gameInfo.isConnectedToClient();
        }
        if (enable) { playButton.enable(); }
        else { playButton.disable(); }
    });
    playButton.disable().setX(300).setY(350);
    addLocalItem(playButton);

    Button helpButton = new Button("ButtonHelp", 200, 40, "Help", () -> {
        trySwitchPage(new HelpPage(this));
    });
    helpButton.setX(300).setY(400);
    addLocalItem(helpButton);

    Label playerNamePrompt1 = new Label("PlayerNamePrompt1", 150, 50, "Player 1 :");
    playerNamePrompt1.setTextAlignHorizon(RIGHT).setRightX(200).setY(500);
    addLocalItem(playerNamePrompt1);
    InputBox playerName1 = new InputBox("InputBoxPlayerName1", 300, 50, 15, (bx, oStr, nStr) -> {
        gameInfo.setPlayerName1(nStr);
        if (nStr.length() <= 0) { playButton.disable(); }
    });
    playerName1.setDefaultText("Happy Bunny")
      .setUpdater(() -> { playerName1.setText(gameInfo.getPlayerName1()); })
      .setCenterX(400).setY(500);
    addLocalItem(playerName1);

    Label playerNamePrompt2 = new Label("PlayerNamePrompt2", 150, 50, "Player 2 :");
    playerNamePrompt2.setTextAlignHorizon(RIGHT).setRightX(200).setY(560);
    addLocalItem(playerNamePrompt2);
    InputBox playerName2 = new InputBox("InputBoxPlayerName2", 300, 50, 15, (bx, oStr, nStr) -> {
        gameInfo.setPlayerName2(nStr);
        if (nStr.length() <= 0) { playButton.disable(); }
    });
    playerName2.setDefaultText("Merry Kitty")
      .setUpdater(() -> { playerName2.setText(gameInfo.getPlayerName2()); })
      .setCenterX(400).setY(560);
    addLocalItem(playerName2);

    Label ipPrompt = new Label("IpPrompt", 150, 40, "Game Lobby :");
    ipPrompt.setTextAlignHorizon(RIGHT).setRightX(450).setY(300);
    addLocalItem(ipPrompt);
    InputBox ipBox = new InputBox("IpBox", 300, 40, 15, (bx, oStr, nStr) -> {});
    ipBox.setX(450).setY(300);
    addLocalItem(ipBox);

    Button createGameButton = new Button("CreateGame", 200, 40, "Create Game", () -> {
        if (!gameInfo.isServerHost()) { gameInfo.startSyncAsServer(); }
        else { gameInfo.stopSyncAsServer(); }
    });
    createGameButton.setX(550).setY(350);
    addLocalItem(createGameButton);
    Button joinGameButton = new Button("JoinGame", 200, 40, "Join Game", () -> {
        if (!gameInfo.isClientHost()) { gameInfo.startSyncAsClient(ipBox.getText()); }
        else { gameInfo.stopSyncAsClient(); }
    });
    joinGameButton.setX(550).setY(400);
    addLocalItem(joinGameButton);
  }

  @Override
  public void dispatchSyncInfo(JSONObject json) {
    // TODO: For server, illegal player name after start button clicked;
    super.dispatchSyncInfo(json);
    // TODO: For server, connection close after start button clicked;

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
    Button playButton = (Button)getLocalItem("ButtonPlay");
    InputBox ipBox = (InputBox)getLocalItem("IpBox");
    InputBox playerName1 = (InputBox)getLocalItem("InputBoxPlayerName1");
    InputBox playerName2 = (InputBox)getLocalItem("InputBoxPlayerName2");
    if (gameInfo.isServerHost()) {
      createGameButton.enable().setText("Leave Game");
      joinGameButton.disable().setText("Join Game");
      playButton.disable().setText("Start Online");
      ipBox.disable().setText(gameInfo.getIpAddr());
      playerName1.enable();
      playerName2.disable().setText("");
    } else if (gameInfo.isClientHost()) {
      createGameButton.disable().setText("Create Game");
      joinGameButton.enable().setText("Leave Game");
      ipBox.disable();
      playButton.disable().setText("Start");
      playerName1.disable().setText("");
      playerName2.enable();
    } else {
      createGameButton.enable().setText("Create Game");
      joinGameButton.enable().setText("Join Game");
      ipBox.enable();
      playButton.disable().setText("Start");
      playerName1.enable();
      playerName2.enable();
    }
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageGameBanner, 145, 150, 509, 165);
  }
}
