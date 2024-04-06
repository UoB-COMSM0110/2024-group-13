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

    InputBox playerName1 = new InputBox("InputBoxPlayerName1", 300, 50, 15);
    playerName1.setCallback((box) -> { gameInfo.setPlayerName1(box.getText()); })
      .setDefaultText("Happy Bunny")
      .setPrefix(" Player 1 : ")
      .setUpdater(() -> { playerName1.setText(gameInfo.getPlayerName1()); })
      .setCenterX(400).setY(500);
    addLocalItem(playerName1);

    InputBox playerName2 = new InputBox("InputBoxPlayerName2", 300, 50, 15);
    playerName2.setCallback((box) -> { gameInfo.setPlayerName2(box.getText()); })
      .setDefaultText("Merry Kitty")
      .setPrefix(" Player 2 : ")
      .setUpdater(() -> { playerName2.setText(gameInfo.getPlayerName2()); })
      .setCenterX(400).setY(560);
    addLocalItem(playerName2);

    Button createGameButton = new Button("CreateGame", 200, 40, "Create Game", () -> {
      try { gameInfo.startSyncAsServer(); }
      catch (Exception e) {
        System.err.println("when creating game: " + e.toString());
        gameInfo.stopSyncAsServer();
      }
    });
    createGameButton.setX(550).setY(350);
    addLocalItem(createGameButton);
    Button joinGameButton = new Button("JoinGame", 200, 40, "Join Game", () -> {
      try { gameInfo.startSyncAsClient(); }
      catch (Exception e) {
        System.err.println("when joining game: " + e.toString());
        gameInfo.stopSyncAsClient();
      }
    });
    joinGameButton.setX(550).setY(400);
    addLocalItem(joinGameButton);
  }

  @Override
  public void draw() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageGameBanner, 145, 150, 509, 165);
    super.draw();
  }
}
