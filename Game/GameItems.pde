
final String imagePathBreakableWall = "data/BreakableWall.png";
PImage imageBreakableWall;
final String imagePathIndestructableWall = "data/IndestructableWall.png";
PImage imageIndestructableWall;
final String imagePathCoin = "data/Coin.png";
PImage imageCoin;
final String imagePathPowerUp = "data/PowerUp.png";
PImage imagePowerUp;
final String imagePathPacman = "data/Coin.png";
PImage imagePacman;
final String imagePathBullet = "data/Bullet.JPG";
PImage imageBullet;


void loadResoucesForGameItems() {
  imageBreakableWall = loadImage(imagePathBreakableWall);
  imageIndestructableWall = loadImage(imagePathIndestructableWall);
  imageCoin = loadImage(imagePathCoin);
  imagePowerUp = loadImage(imagePathPowerUp);
  imagePacman = loadImage(imagePathPacman);
  imageBullet = loadImage(imagePathBullet);
}


public abstract class Wall extends SynchronizedItem {
  public Wall(String name, float w, float h) {
    super(name, w, h);
  }
}


final String itemTypeBreakableWall = "BreakableWall";
int itemCountBreakableWall;

public class BreakableWall extends Wall {
  private int strength;

  public BreakableWall(float w, float h) {
    super(itemTypeBreakableWall + itemCountBreakableWall++, w, h);
    strength = 3;
  }
  
  public int getStrength() {
    return this.strength;
  }
  
  public BreakableWall setStrength(int strength) {
    this.strength = strength;
    return this;
  }

  @Override
  public PImage getImage() {
    return imageBreakableWall;
  }
}


final String itemTypeIndestructableWall = "IndestructableWall";
int itemCountIndestructableWall;

public class IndestructableWall extends Wall {
  public IndestructableWall(float w, float h) {
    super(itemTypeIndestructableWall + itemCountIndestructableWall++, w, h);
  }

  @Override
  public PImage getImage() {
    return imageIndestructableWall;
  }
}

final String itemTypeCoin = "Coin";
int itemCountCoin;

public class Coin extends SynchronizedItem {
  public Coin(float w, float h) {
    super(itemTypeCoin + itemCountCoin++, w, h);
  }

  @Override
  public void onCollisionWith(GameInfo gInfo, Page page, SynchronizedItem item) {
    if(item instanceof Pacman){
      discard();
    }
  }

  @Override
  public PImage getImage() {
    return imageCoin;
  }
}


final String itemTypePowerUp = "PowerUp";
int itemCountPowerUp;

public class PowerUp extends SynchronizedItem {
  public PowerUp(float w, float h) {
    super(itemTypePowerUp + itemCountPowerUp++, w, h);
  }

  @Override
  public void onCollisionWith(GameInfo gInfo, Page page, SynchronizedItem item) {
    if(item instanceof Pacman){
      discard();
    }
  }  

  @Override
  public PImage getImage() {
    return imagePowerUp;
  }
}


final String itemTypePacman = "Pacman";

public class Pacman extends MovableItem {
  private int playerId;
  private int score;

  public Pacman(int playerId, float w, float h) {
    super(itemTypePacman + playerId, w, h);
    this.playerId = playerId;
  }

  public PImage getImage() {
    return imagePacman;
  }
  
  public int getScore(){
    return this.score; 
  }

  public void incScore(int increment){
    this.score += increment;
  }

  @Override
  public void onCollisionWith(GameInfo gInfo, Page page, SynchronizedItem item, float dx, float dy) {
    if(item instanceof Coin){
      incScore(1);
    } else if (item instanceof Wall) {
      moveX(dx);
      moveY(dy);
    }
  }
  
  @Override
  public void onKeyboardEvent(GameInfo gInfo, Page page, KeyboardEvent e) {
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

final String itemTypeBullet = "Bullet";
int itemCountBullet;

public class Bullet extends MovableItem {
  
  public Bullet(float w, float h) {
    super(itemTypeBullet + itemCountBullet++, w, h);
  }
  
  public void onCollisionWith(GameInfo gInfo, SynchronizedItem item) {
    
    if(item instanceof IndestructableWall){
      discard();
    }
    
    if(item instanceof BreakableWall) {
      BreakableWall breakableWall = (BreakableWall)item;
      if (breakableWall.getStrength() == 1) {
        breakableWall.setStrength(0);
        breakableWall.discard();
        this.discard();
      } else {
        breakableWall.setStrength(breakableWall.getStrength() - 1);
        this.discard();
      }
    }
    
    if (item instanceof Ghost) {
      Ghost ghost = (Ghost)item;
      if (ghost.getGhostLife() == 1) {
        ghost.setGhostLife(0);
        ghost.discard();
        this.discard();
      } else {
        ghost.setGhostLife(ghost.getGhostLife() - 1);
        this.discard();
      }
    }
  }  
  
  public PImage getImage() {
    return imageBullet;
  }
}
