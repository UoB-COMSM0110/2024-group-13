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
  
  public int getStrength() {
    return this.strength;
  }
  
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
  public PowerUp(float w, float h) {
    super(itemTypePowerUp + itemCountPowerUp++, w, h);
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

public class Bullet extends MovableItem {
  
  public Bullet(float w, float h) {
    super(itemTypeBullet + itemCountBullet++, w, h);
    setSpeed(200.0);
    startMoving();
  }

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
