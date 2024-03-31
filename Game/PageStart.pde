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

    InputBox playerName1 = new InputBox("InputBoxPlayerName1", 300, 50, 15, (box) -> {
      gameInfo.setPlayerName1(box.getText());
    });
    playerName1.setDefaultText("Happy Bunny").setPrefix(" Player 1 : ").setCenterX(400).setY(500);
    addLocalItem(playerName1);

    InputBox playerName2 = new InputBox("InputBoxPlayerName2", 300, 50, 15, (box) -> {
      gameInfo.setPlayerName2(box.getText());
    });
    playerName2.setDefaultText("Merry Kitty").setPrefix(" Player 2 : ").setCenterX(400).setY(560);
    addLocalItem(playerName2);

    Button createGameButton = new Button("CreateGame", 200, 40, "Create Game", () -> {
      try { gameInfo.startSyncAsServer(); }
      catch (Exception e) {
        System.out.println(e.toString());
        gameInfo.stopSyncAsServer();
      }
    });
    createGameButton.setX(550).setY(350);
    addLocalItem(createGameButton);
  }

  @Override
  public void draw() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageGameBanner, 145, 150, 509, 165);
    super.draw();
  }
}
