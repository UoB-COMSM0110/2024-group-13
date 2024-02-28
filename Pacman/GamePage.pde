final static float CHARACTER_SIZE = 10;

public class GamePage extends Page {
  public GamePage(GameInfo gInfo, Page previousPage) {
    super(gInfo, previousPage);

    Button backButton = new Button("Back", 300, 350, "Back");
    backButton.setW(200).setH(40);
    addLocalItem(backButton);

    createPlatforms("data/GUI/map.csv");

  }

  @Override
  public void draw(GameInfo gInfo) {
    PImage backgroundImage = loadImage("data/GUI/BackgroundEarthImage.png");
    image(backgroundImage, 0, 0, 800, 600);
    super.draw(gInfo);
  }

  void createPlatforms(String filename){
    int itemCounter = 0;

    String[] lines = loadStrings(filename);
    for (int row = 0; row <lines.length; row++) {
      String[] values = split(lines[row], ",");
      for (int col = 0; col < values.length; col++) {
        //destructable walls
        if (values[col].equals("1")) {
          float x = CHARACTER_SIZE/2 + col * CHARACTER_SIZE;
          float y = CHARACTER_SIZE/2 + row * CHARACTER_SIZE;
          itemCounter++;
          String name = "breakableWall" + itemCounter;
          Item breakableWall = new BreakableWall(name, x, y);
          addSyncItem((SynchronizedItem)breakableWall);
        }
        //indestructable walls
        else if (values[col].equals("2")) {
          float x = CHARACTER_SIZE/2 + col * CHARACTER_SIZE;
          float y = CHARACTER_SIZE/2 + row * CHARACTER_SIZE;
          itemCounter++;
          String name = "indestructableWall" + itemCounter;
          Item indestructableWall = new IndestructableWall(name, x, y);
          addLocalItem((LocalItem)indestructableWall);
        }
        //coin
        else if (values[col].equals("3")) {
          float x = CHARACTER_SIZE/2 + col * CHARACTER_SIZE;
          float y = CHARACTER_SIZE/2 + row * CHARACTER_SIZE;
          itemCounter++;
          String name = "coin" + itemCounter;
          Item coin = new Coin(name, x, y);
          addSyncItem((SynchronizedItem)coin);
        }
        //indestructable walls
        else if (values[col].equals("4")) {
          float x = CHARACTER_SIZE/2 + col * CHARACTER_SIZE;
          float y = CHARACTER_SIZE/2 + row * CHARACTER_SIZE;
          itemCounter++;
          String name = "powerUp" + itemCounter;
          Item powerUp = new PowerUp(name, x, y);
          addSyncItem((SynchronizedItem)powerUp);
        }
      }
    }
  }
}
