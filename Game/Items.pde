// This file defines most map items in the game.
// This items are Synchronized items.

final String imagePathBreakableWall = "data/BreakableWall.png";
PImage imageBreakableWall;
final String imagePathIndestructableWall = "data/IndestructableWall.png";
PImage imageIndestructableWall;
final String imagePathCoin = "data/Coin.png";
PImage imageCoin;
final String imagePathBullet = "data/Bullet.png";
PImage imageBullet;


void loadResoucesForItems() {
  imageBreakableWall = loadImage(imagePathBreakableWall);
  imageIndestructableWall = loadImage(imagePathIndestructableWall);
  imageCoin = loadImage(imagePathCoin);
  imageBullet = loadImage(imagePathBullet);
}


public class Border extends SynchronizedItem {
  private int forbiddenDirection;

  public Border(String name, float w, float h, int forbiddenDirection) {
    super(name, w, h);
    this.forbiddenDirection = forbiddenDirection;
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setInt("forbiddenDirection", this.forbiddenDirection);
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    this.forbiddenDirection = json.getInt("forbiddenDirection");
  }
  
  @Override
  public void onCollisionWith(SynchronizedItem item) {
    // `item` can only be instance of MovableItem
    if (item instanceof Figure) {
      ((Figure)item).tryPushbackFrom(this, this.forbiddenDirection);
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
final int breakableWallStrength = 2;
final float breakableWallRestoreTimeS = 10.0;

public class BreakableWall extends Wall {
  private int strength;

  public BreakableWall() {
    super(itemTypeBreakableWall + itemCountBreakableWall++,
        CHARACTER_SIZE, CHARACTER_SIZE);
    setStrength(breakableWallStrength);
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
  public BreakableWall setStrength(int strength) {
    this.strength = strength;
    return this;
  }
  
  public BreakableWall decStrength() {
    this.strength -= 1;
    if (this.strength <= 0) {
      discardFor(breakableWallRestoreTimeS);
      setStrength(breakableWallStrength);
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
  public IndestructableWall() {
    super(itemTypeIndestructableWall + itemCountIndestructableWall++,
        CHARACTER_SIZE, CHARACTER_SIZE);
  }

  @Override
  public PImage getImage() {
    return imageIndestructableWall;
  }
}


final String itemTypeCoin = "Coin";
int itemCountCoin;
final float coinRestoreTimeS = 30.0;

public class Coin extends SynchronizedItem {
  public Coin() {
    super(itemTypeCoin + itemCountCoin++, CHARACTER_SIZE, CHARACTER_SIZE);
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if(item instanceof Pacman){
      discardFor(coinRestoreTimeS);
    }
  }

  @Override
  public PImage getImage() {
    return imageCoin;
  }
}


final String itemTypeBullet = "Bullet";
int itemCountBullet;
final float defaultBulletSpeed = 200.0;

public class Bullet extends MovableItem {
  private int owner;

  public Bullet(int owner) {
    super(itemTypeBullet + itemCountBullet++, CHARACTER_SIZE, CHARACTER_SIZE);
    this.owner = owner;
    startMoving();
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setInt("owner", getOwner());
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    this.owner = json.getInt("owner");
  }

  public boolean isFiredBy(Pacman pacman) { return isFiredBy(pacman.getPlayerId()); }
  public boolean isFiredBy(int playerId) { return getOwner() == playerId; }
  public int getOwner() { return this.owner; }
  
  @Override
  public void move() {
    super.move();
    setSpeed(defaultBulletSpeed);
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    // Note, not discarded before deleted,
    // so a single bullet can collide with multiple targets.
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


final String itemTypePacmanShelter = "PacmanShelter";

public class PacmanShelter extends SynchronizedItem {
  private int owner;

  public PacmanShelter(int owner) {
    super(itemTypePacmanShelter + owner, 2.8 * CHARACTER_SIZE, 2.8 * CHARACTER_SIZE);
    this.owner = owner;
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setInt("owner", getOwner());
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    this.owner = json.getInt("owner");
  }

  public boolean isUsedBy(Pacman pacman) { return isUsedBy(pacman.getPlayerId()); }
  public boolean isUsedBy(int playerId) { return getOwner() == playerId; }
  public int getOwner() { return this.owner; }
  
  @Override
  public void onCollisionWith(SynchronizedItem item) {
    // `item` can only be instance of MovableItem
    if (item instanceof Figure) {
      if (item instanceof Pacman) {
        if (isUsedBy((Pacman)item)) { return; }
      }
      ((Figure)item).tryPushbackFrom(this, item.getDirectionOf(this));
    } else {
      if (item instanceof Bullet) {
        if (((Bullet)item).isFiredBy(getOwner())) { return; }
      }
      item.discard().delete();
    }
  }

  @Override
  public void drawLocally(float x, float y, float w, float h) {
    int fillColor;
    switch (getOwner()) {
      case 1: { fillColor = color(255, 102, 178); break; }
      case 2: { fillColor = color(204, 255, 153); break; }
      default: fillColor = color(255);
    }
    noStroke();
    fill(fillColor, 200.0);
    rect(x, y, w, h, 2.0);
    super.drawLocally(x, y, w, h);
  }
}


final String itemTypeViewShader = "ViewShader";

// ViewShader can also be implemented as a LocalItem.
public class ViewShader extends SynchronizedItem {
  public ViewShader() {
    super(itemTypeViewShader, 0.0, 0.0);
    setLayer(9);
  }

  @Override
  public void draw() { // Runs locally.
    if (gameInfo.isSingleHost()) { return; }
    int playerId = gameInfo.isServerHost() ? 1 : 2;
    Pacman pacman = (Pacman)page.getSyncItem(itemTypePacman + playerId);
    if (pacman.getViewFactor() >= 1.0) { return; }
    float[] coord = page.getLocalCoord(pacman.getCenterX(), pacman.getCenterY(), 0, 0);
    shadeLocally(coord[0], coord[1]);
  }

  public void shadeLocally(float x, float y) {
    float step = 5.0;
    strokeWeight(step);
    noFill();
    int c = color(0);
    float winW = gameInfo.getWinWidth();
    float winH = gameInfo.getWinHeight();
    float rStart = Math.min(winW, winH) / 2.5;
    float rEnd = (float)Math.sqrt(winW * winW + winH * winH);
    float r = rStart;
    while (r < rEnd) {
      float f = (r - rStart) / (rEnd - rStart);
      f = Math.min(f, 1.0);
      f = 1.0 - (float)Math.pow((1.0 - f), 15.0);
      if (f >= 0.98) { // Saves cpu resource.
        stroke(c);
        float finalStep = rEnd - r;
        strokeWeight(finalStep);
        circle(x, y, 2.0 * r + finalStep);
        break;
      }
      float alpha = 255.0 * f;
      stroke(c, alpha);
      circle(x, y, 2.0 * r + step);
      r += step;
    }
  }
}
