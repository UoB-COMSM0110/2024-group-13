final String imagePathPlayPageBackground = "data/PlayPageBackground.png";
PImage imagePlayPageBackground;

void loadResourcesForPlayPage() {
  imagePlayPageBackground = loadImage(imagePathPlayPageBackground);
}


final String mapPath = "data/map.csv";
final float CHARACTER_SIZE = 10.0;

public class PlayPage extends Page {
  public PlayPage(Page previousPage) {
    super(previousPage);

    Button backButton = new Button("ButtonBack", 200, 40, "Back", () -> {
      trySwitchPage(getPreviousPage());
    });
    backButton.setX(20).setY(10);
    addLocalItem(backButton);

    loadMap(mapPath);

    float borderSize = 10.0;
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

    Pacman pacman1 = new Pacman(1, 18, 18);
    pacman1.setX(360).setY(270);
    addSyncItem(pacman1);
    Label score1 = new Label("Score1", 180, 25, "0");
    score1.setPrefix("Player 1: ").setTextAlignHorizon(LEFT).setX(600).setY(15);
    addLocalItem(score1);

    Pacman pacman2 = new Pacman(2, 18, 18);
    pacman2.setX(360).setY(350);
    addSyncItem(pacman2);
    Label score2 = new Label("Score2", 180, 25, "0");
    score2.setPrefix("Player 2: ").setTextAlignHorizon(LEFT).setX(600).setY(40);
    addLocalItem(score2);
    
    Ghost ghost1 = new Ghost(20, 20);
    ghost1.setX(30).setY(100);
    addSyncItem(ghost1);
  }

  @Override
  public void draw() {
    image(imagePlayPageBackground, 0, 0, 800, 600);
    super.draw();
  }

  void loadMap(String mapPath) {
    String[] lines = loadStrings(mapPath);
    for (int row = 0; row <lines.length; row++) {
      String[] values = split(lines[row], ",");
      for (int col = 0; col < values.length; col++) {
        float x = CHARACTER_SIZE / 2 + col * CHARACTER_SIZE;
        float y = CHARACTER_SIZE / 2 + row * CHARACTER_SIZE;
        //destructable walls
        if (values[col].equals("1")) {
          BreakableWall breakableWall =
            new BreakableWall(CHARACTER_SIZE, CHARACTER_SIZE);
          breakableWall.setX(x).setY(y);
          addSyncItem(breakableWall);
        }
        
        //indestructable walls
        else if (values[col].equals("2")) {
          IndestructableWall indestructableWall =
            new IndestructableWall(CHARACTER_SIZE, CHARACTER_SIZE);
          indestructableWall.setX(x).setY(y);
          addSyncItem(indestructableWall);
        }
        //coin
        else if (values[col].equals("3")) {
          Coin coin = new Coin(CHARACTER_SIZE, CHARACTER_SIZE);
          coin.setX(x).setY(y);
          addSyncItem(coin);
        }
        //indestructable walls
        else if (values[col].equals("4")) {
          PowerUp powerUp = new PowerUp(CHARACTER_SIZE, CHARACTER_SIZE);
          powerUp.setX(x).setY(y);
          addSyncItem(powerUp);
        }
      }
    }
  }
}
