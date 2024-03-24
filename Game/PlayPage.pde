final String imagePathPlayPageBackground = "data/PlayPageBackground.png";
PImage imagePlayPageBackground;

void loadResourcesForPlayPage() {
  imagePlayPageBackground = loadImage(imagePathPlayPageBackground);
}


final String mapPath = "data/map.csv";
float CHARACTER_SIZE = 10.0;

public class PlayPage extends Page {
  private Pacman pac1;  

  public PlayPage(Page previousPage) {
    super(previousPage);

    Button backButton = new Button("Back", 200, 40, "Back");
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

    pac1 = new Pacman(0, 20, 20);
    pac1.setX(360).setY(350);
    addSyncItem(pac1);
    
    Ghost goo = new Ghost(20, 20);
    goo.setX(30).setY(100);
    addSyncItem(goo);
  }

  @Override
  public void draw() {
    image(imagePlayPageBackground, 0, 0, 800, 600);
    super.draw();
    
    textSize(20);
    text("Score: " + pac1.getScore(), 700, 40);
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
