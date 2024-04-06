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
    playButton.setX(300).setY(350);
    addLocalItem(playButton);

    Button helpButton = new Button("ButtonHelp", 200, 40, "Help", () -> {
      trySwitchPage(new HelpPage(this));
    });
    helpButton.setX(300).setY(400);
    addLocalItem(helpButton);

    InputBox playerName1 = new InputBox("InputBoxPlayerName1", 300, 50, 15,
        (box) -> { gameInfo.setPlayerName1(box.getText()); });
    playerName1.setDefaultText("Happy Bunny")
      .setPrefix(" Player 1 : ")
      .setUpdater(() -> { playerName1.setText(gameInfo.getPlayerName1()); })
      .setCenterX(400).setY(500);
    addLocalItem(playerName1);

    InputBox playerName2 = new InputBox("InputBoxPlayerName2", 300, 50, 15,
        (box) -> { gameInfo.setPlayerName2(box.getText()); });
    playerName2.setDefaultText("Merry Kitty")
      .setPrefix(" Player 2 : ")
      .setUpdater(() -> { playerName2.setText(gameInfo.getPlayerName2()); })
      .setCenterX(400).setY(560);
    addLocalItem(playerName2);

    Button createGameButton = new Button("CreateGame", 200, 40, "Create Game", () -> {
      try {
        if (!gameInfo.isServerHost()) {
          gameInfo.startSyncAsServer();
          adjustWidgets();
        } else {
          gameInfo.stopSyncAsServer();
          onConnectionClose();
        }
      } catch (Exception e) {
        onNetworkFailure("creating game", e);
      }
    });
    createGameButton.setX(550).setY(350);
    addLocalItem(createGameButton);
    Button joinGameButton = new Button("JoinGame", 200, 40, "Join Game", () -> {
      try {
        if (!gameInfo.isClientHost()) {
          gameInfo.startSyncAsClient();
          adjustWidgets();
        } else {
          gameInfo.stopSyncAsClient();
          onConnectionClose();
        }
      } catch (Exception e) {
        onNetworkFailure("joining game", e);
      }
    });
    joinGameButton.setX(550).setY(400);
    addLocalItem(joinGameButton);

    adjustWidgets();
  }

  @Override
  public void onConnectionClose() {
    adjustWidgets();
  }

  public void adjustWidgets() {
    Button createGameButton = (Button)getLocalItem("CreateGame");
    Button joinGameButton = (Button)getLocalItem("JoinGame");
    Button playButton = (Button)getLocalItem("ButtonPlay");
    InputBox playerName1 = (InputBox)getLocalItem("InputBoxPlayerName1");
    InputBox playerName2 = (InputBox)getLocalItem("InputBoxPlayerName2");
    if (gameInfo.isServerHost()) {
      createGameButton.enable().setText("Leave Game");
      joinGameButton.disable().setText("Join Game");
      playButton.enable().setText("Start Online");
      playerName1.enable();
      playerName2.disable();
    } else if (gameInfo.isClientHost()) {
      createGameButton.disable().setText("Create Game");
      joinGameButton.enable().setText("Leave Game");
      playButton.disable().setText("Start Online");
      playerName1.disable();
      playerName2.enable();
    } else {
      createGameButton.enable().setText("Create Game");
      joinGameButton.enable().setText("Join Game");
      playButton.enable().setText("Start");
      playerName1.enable();
      playerName2.enable();
    }
  }

  @Override
  public JSONObject getSyncInfo() {
    JSONObject json = super.getSyncInfo();
    json.setString("player1", gameInfo.getPlayerName1());
    json.setString("player2", gameInfo.getPlayerName2());
    return json;
  }

  @Override
  public void dispatchSyncInfo(JSONObject json) {
    if (getName().equals(json.getString("page"))) {
      if (gameInfo.isServerHost()) {
        ((InputBox)getLocalItem("InputBoxPlayerName2")).setText(json.getString("player2"));
      }
      if (gameInfo.isClientHost()) {
        ((InputBox)getLocalItem("InputBoxPlayerName1")).setText(json.getString("player1"));
      }
    }
    super.dispatchSyncInfo(json);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageGameBanner, 145, 150, 509, 165);
  }
}
