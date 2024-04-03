// This file defines most map items in the game.
// This items are Synchronized items.

final String imagePathBreakableWall = "data/BreakableWall.png";
PImage imageBreakableWall;
final String imagePathIndestructableWall = "data/IndestructableWall.png";
PImage imageIndestructableWall;
final String imagePathCoin = "data/Coin.png";
PImage imageCoin;
final String imagePathPowerUp = "data/PowerUp.png";
PImage imagePowerUp;
final String imagePathBullet = "data/Bullet.JPG";
PImage imageBullet;


void loadResoucesForGameItems() {
  imageBreakableWall = loadImage(imagePathBreakableWall);
  imageIndestructableWall = loadImage(imagePathIndestructableWall);
  imageCoin = loadImage(imagePathCoin);
  imagePowerUp = loadImage(imagePathPowerUp);
  imageBullet = loadImage(imagePathBullet);
}


public class Border extends SynchronizedItem {
  public Border(String name, float w, float h) {
    super(name, w, h);
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    // `item` can only be instance of MovableItem
    if (item instanceof Figure) {
      ((Figure)item).tryStepbackFrom(this);
    } else {
      item.discard().delete();
    }
  }
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

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setInt("strength", getStrength());
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    setStrength(json.getInt("strength"));
  }
  
  public int getStrength() { return this.strength; }

  public BreakableWall setStrength(int strength) { this.strength = strength; return this; }
  
  public BreakableWall decStrength() {
    this.strength -= 1;
    if (this.strength <= 0) {
      discard();
    }
    return this;
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Bullet) {
      decStrength();
    }
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
  public void onCollisionWith(SynchronizedItem item) {
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
  
  private boolean inUse = false;
  
  public PowerUp(float w, float h) {
    super(itemTypePowerUp + itemCountPowerUp++, w, h);
  }
  
  public boolean getInUse() {
    return this.inUse;
  }
  
  public PowerUp setInUse(boolean status) {
    this.inUse = status;
    return this;
  }
  

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if(item instanceof Pacman){
      discard();
    }
  }  

  @Override
  public PImage getImage() {
    return imagePowerUp;
  }
}


final String itemTypeBullet = "Bullet";
int itemCountBullet;
final float defaultBulletSpeed = 200.0;

public class Bullet extends MovableItem {
  public Bullet(float w, float h) {
    super(itemTypeBullet + itemCountBullet++, w, h);
    startMoving();
  }

  @Override
  public void move() {
    super.move();
    setSpeed(defaultBulletSpeed);
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if(item instanceof Wall){
      delete();
    } else if (item instanceof Figure) {
      delete();
    }
  }  
  
  public PImage getImage() {
    return imageBullet;
  }
}
