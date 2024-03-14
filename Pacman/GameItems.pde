final String itemTypeBreakableWall = "BreakableWall";
int itemCountBreakableWall;
String imagePathBreakableWall = "data/BreakableWall.png";
PImage imageBreakableWall;

public class BreakableWall extends SynchronizedItem {
  public int strength;

  public BreakableWall(float w, float h) {
    super(itemTypeBreakableWall + itemCountBreakableWall++, w, h);
    strength = 3;
    if (imageBreakableWall == null ) {
      imageBreakableWall = loadImage(imagePathBreakableWall);
    }
  }

  public PImage getImage() {
    return imageBreakableWall;
  }
}


final String itemTypeIndestructableWall = "IndestructableWall";
int itemCountIndestructableWall;
String imagePathIndestructableWall = "data/IndestructableWall.png";
PImage imageIndestructableWall;

public class IndestructableWall extends SynchronizedItem {
  public IndestructableWall(float w, float h) {
    super(itemTypeIndestructableWall + itemCountIndestructableWall++, w, h);
    if (imageIndestructableWall == null ) {
      imageIndestructableWall = loadImage(imagePathIndestructableWall);
    }
  }

  public PImage getImage() {
    return imageIndestructableWall;
  }
}

final String itemTypeCoin = "Coin";
int itemCountCoin;
String imagePathCoin = "data/Coin.png";
PImage imageCoin;

public class Coin extends SynchronizedItem {
  public Coin(float w, float h) {
    super(itemTypeCoin + itemCountCoin++, w, h);
    if (imageCoin == null ) {
      imageCoin = loadImage(imagePathCoin);
    }
  }

  public void onCollisionWith(GameInfo gInfo, SynchronizedItem item) {
    if(item instanceof PacmanFigure){
      setDiscarded();
      item.setScore(1);
    }
  }

  public PImage getImage() {
    return imageCoin;
  }
}


final String itemTypePowerUp = "PowerUp";
int itemCountPowerUp;
String imagePathPowerUp = "data/PowerUp.png";
PImage imagePowerUp;

public class PowerUp extends SynchronizedItem {
  public PowerUp(float w, float h) {
    super(itemTypePowerUp + itemCountPowerUp++, w, h);
    if (imagePowerUp == null ) {
      imagePowerUp = loadImage(imagePathPowerUp);
    }
  }

  public void onCollisionWith(GameInfo gInfo, SynchronizedItem item) {
    if(item instanceof PacmanFigure){
      setDiscarded();
    }
  }  

  public PImage getImage() {
    return imagePowerUp;
  }
}


final String itemTypePacmanFigure = "PacmanFigure";
String imagePathPacmanFigure = "data/Coin.png";
PImage imagePacmanFigure;

public class PacmanFigure extends MovableItem {
  private int playerId;
  private int score;

  public PacmanFigure(int playerId, float w, float h) {
    super(itemTypePacmanFigure + playerId, w, h);
    this.playerId = playerId;
  }

  public PImage getImage() {
    if (imagePacmanFigure == null ) {
      imagePacmanFigure = loadImage(imagePathPacmanFigure);
    }
    return imagePacmanFigure;
  }
  
  public int getScore(){
    return this.score; 
  }
  
  public void setScore(int increment){
    this.score += increment;
  }
    
  public void onKeyboardEvent(GameInfo gInfo, KeyboardEvent e) {
    System.out.println("player key event");
    if (e instanceof KeyPressedEvent) {
      onKeyPressedEvent(gInfo, (KeyPressedEvent)e);
    } else if (e instanceof KeyReleasedEvent) {
      onKeyReleasedEvent(gInfo, (KeyReleasedEvent)e);
    }
  }

  public void onKeyPressedEvent(GameInfo gInfo, KeyPressedEvent e) {
    if (e.getKey() == CODED) {
      switch (e.getKeyCode()) {
        case UP: { startMovingUp(); break; }
        case LEFT: { startMovingLeft(); break; }
        case DOWN: { startMovingDown(); break; }
        case RIGHT: { startMovingRight(); break; }
      }
      return;
    }
    switch (e.getKey()) {
      case 'w': case 'W': { startMovingUp(); break; }
      case 'a': case 'A': { startMovingLeft(); break; }
      case 's': case 'S': { startMovingDown(); break; }
      case 'd': case 'D': { startMovingRight(); break; }
    }
  }

  public void onKeyReleasedEvent(GameInfo gInfo, KeyReleasedEvent e) {
    if (e.getKey() == CODED) {
      switch (e.getKeyCode()) {
        case UP: case LEFT: case DOWN: case RIGHT: { stopMoving(); break; }
      }
      return;
    }
    switch (e.getKey()) {
      case 'w': case 'W': case 'a': case 'A':
      case 's': case 'S': case 'd': case 'D': { stopMoving(); break; }
    }
  }

  public void startMovingUp() {
    setFacing(UPWARD);
    setDirection(UPWARD);
    startMoving();
  }
  public void startMovingRight() {
    setFacing(RIGHTWARD);
    setDirection(RIGHTWARD);
    startMoving();
  }
  public void startMovingDown() {
    setFacing(DOWNWARD);
    setDirection(DOWNWARD);
    startMoving();
  }
  public void startMovingLeft() {
    setFacing(LEFTWARD);
    setDirection(LEFTWARD);
    startMoving();
  }
}
