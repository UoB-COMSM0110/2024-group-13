void loadResourcesForPlayPage() {
}


final String mapPath = "data/map.csv";
final float CHARACTER_SIZE = 10.0;

public class PlayPage extends Page {
  
  private ArrayList<PowerUp> powerups = new ArrayList<>();
  
  public PlayPage(Page previousPage) {
    super(previousPage);

    Button backButton = new Button("ButtonBack", 200, 40, "Back", () -> {
      trySwitchPage(getPreviousPage());
    });
    backButton.setX(20).setY(10);
    addLocalItem(backButton);
    Label fps = new Label("Fps", 200, 25, "");
    fps.setPrefix("fps: ").setX(250).setY(10);
    addLocalItem(fps);
    addTimer(new Timer(0.0, 1.0, () -> {
          Label fpsLabel = (Label)getLocalItem("Fps");
          if (fpsLabel != null) { fpsLabel.setText(String.format("%.2f", gameInfo.getAvgFps())); }
    }));
    
    // generate powerups
    OpponentControlPowerUp oc = new OpponentControlPowerUp(CHARACTER_SIZE, CHARACTER_SIZE);
    powerups.add(oc);

    loadMap(mapPath);

    float borderSize = 3.0;
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
    Label score1 = new Label("Score1", 200, 25, "0");
    score1.setPrefix(gameInfo.getPlayerName1() + ": ").setX(600).setY(15);
    addLocalItem(score1);

    Pacman pacman2 = new Pacman(2, 18, 18);
    pacman2.setX(360).setY(350);
    addSyncItem(pacman2);
    Label score2 = new Label("Score2", 200, 25, "0");
    score2.setPrefix(gameInfo.getPlayerName2() + ": ").setX(600).setY(40);
    addLocalItem(score2);
    
    Ghost ghost1 = new Ghost(20, 20);
    ghost1.setX(30).setY(100);
    addSyncItem(ghost1);
    
  }

  @Override
  public void draw() {
    background(155, 82, 52);
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
        //PowerUp
        else if (values[col].equals("4")) {
           //PowerUp powerUp = new PowerUp(CHARACTER_SIZE, CHARACTER_SIZE);
           //powerUp.setX(x).setY(y);
           //addSyncItem(powerUp);
           
          PowerUp selectedPowerUp = null;
          if (!powerups.isEmpty()) {
            int randomIndex = (int) random(powerups.size());
            selectedPowerUp = powerups.remove(randomIndex);
          } else {
            // temporary placeholder
            selectedPowerUp = new OpponentControlPowerUp(CHARACTER_SIZE, CHARACTER_SIZE);
          }
          
          selectedPowerUp.setX(x).setY(y);
          addSyncItem(selectedPowerUp);
        }
      }
    }
  }
}
