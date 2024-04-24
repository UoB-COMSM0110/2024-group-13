// The first page of the game.
public class HelpPage extends Page {
  public HelpPage(Page previousPage) {
    super("help", previousPage);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(getPreviousPage()); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
  }

  @Override
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) { return false; }
    if (gameInfo.isClientHost() && json.getString("page").equals("start")
        && json.getString("nextPage").equals("play")) {
      trySwitchPage(new PlayPage(getPreviousPage()));
    }
    return true;
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(imageOverlay, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(imageInstruction, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
    text("Pac-miner: A Subterranean Adventure", 300, 110);
  }
}
