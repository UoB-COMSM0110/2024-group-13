// This file defines most map items in the game.
// This items are Synchronized items.

final String imagePathBreakableWall = "data/BreakableWall.png";
PImage imageBreakableWall;
final String imagePathBreakableWallWeak = "data/BreakableWallWeak.png";
PImage imageBreakableWallWeak;
final String imagePathIndestructableWall = "data/IndestructableWall.png";
PImage imageIndestructableWall;
final String imagePathCoin = "data/Coin.png";
PImage imageCoin;
final String imagePathBullet = "data/Bullet.png";
PImage imageBullet;
final String imagePathShade = "data/Shade.png";
PImage imageShade;


void loadResourcesForItems() {
  imageBreakableWall = loadImage(imagePathBreakableWall);
  imageBreakableWallWeak = loadImage(imagePathBreakableWallWeak);
  imageIndestructableWall = loadImage(imagePathIndestructableWall);
  imageCoin = loadImage(imagePathCoin);
  imageBullet = loadImage(imagePathBullet);
  imageShade = loadImage(imagePathShade);
}


// The border of the map. Invisible. Ensures figures won't go out of the map.
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
    if (this.strength <= 1) {
      return imageBreakableWallWeak;
    }
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
final float defaultBulletSpeed = 220.0;

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
      if ((item instanceof Pacman) && isFiredBy((Pacman)item)) { return; }
      delete();
    }
  }  
  
  public PImage getImage() {
    return imageBullet;
  }
}


final String itemTypePacmanShelter = "PacmanShelter";

// Starting point and safe house for a pacman.
public class PacmanShelter extends SynchronizedItem {
  private int owner;

  public PacmanShelter(int owner) {
    super(itemTypePacmanShelter + owner, 3.5 * CHARACTER_SIZE, 3.5 * CHARACTER_SIZE);
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
    float cx = x + w / 2.0;
    float cy = y + h / 2.0;
    float rectw = w * 0.95;
    float recth = h * 0.95;
    int fillColor;
    switch (getOwner()) {
      case 1: { fillColor = color(255, 102, 178); break; }
      case 2: { fillColor = color(204, 255, 153); break; }
      default: fillColor = color(255);
    }
    noStroke();
    fill(fillColor, 200.0);
    rect(cx - rectw / 2.0, cy - recth / 2.0, rectw, recth, 2.0);
    super.drawLocally(x, y, w, h);
  }
}


final String itemTypeViewShader = "ViewShader";

// ViewShader is used for online version, where player's view is limited.
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
    Pacman pacman = getPacman(playerId);
    if (pacman.getViewFactor() >= 1.0) { return; }
    float[] coord = page.getLocalCoord(pacman.getCenterX(), pacman.getCenterY(), 0, 0);
    shadeLocally(coord[0], coord[1]);
  }

  public void shadeLocally(float cx, float cy) {
    float winW = gameInfo.getWinWidth(); // use window size instead of map size
    float winH = gameInfo.getWinHeight();
    float imgSize = Math.max(winW, winH) * 2;
    float x = cx - imgSize / 2;
    float y = cy - imgSize / 2;
    image(imageShade, x, y, imgSize, imgSize);
  }
}


final String itemTypeGameState = "GameState";

// GameState is a special class.
// Used for storing and synchronising overall game status,
// e.g., whether the game has ended, whether to show the "GameOver" banner, etc.
public class GameState extends SynchronizedItem {
  private boolean isGameOver;
  private int gameOverWaitingTimeMs;
  private boolean showGameOverBanner;

  public GameState() {
    super(itemTypeGameState, 0.0, 0.0);
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setBoolean("isGameOver", this.isGameOver);
    json.setInt("gameOverWaitingTimeMs", this.gameOverWaitingTimeMs);
    json.setBoolean("showGameOverBanner", this.showGameOverBanner);
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    this.isGameOver = json.getBoolean("isGameOver");
    this.gameOverWaitingTimeMs = json.getInt("gameOverWaitingTimeMs");
    this.showGameOverBanner = json.getBoolean("showGameOverBanner");
  }

  // Game over means the game stops and the winner/loser can be decided.
  public boolean isGameOver() { return this.isGameOver; }
  public void gameOver() {
    if (this.isGameOver) { return; }
    this.isGameOver = true;
    this.gameOverWaitingTimeMs = 3000; // 2 second stand-still time.
  }

  // Game finished means the gaming page shall not evolve any more and shall be switched.
  // It differs from 'game over',
  // because we set some stand-still time for the gaming page after game over.
  public boolean isGameFinished() {
    return isGameOver() && this.gameOverWaitingTimeMs <= 0;
  }

  // This method shall be called by the page.
  public void step() {
    if (!isGameOver()) { return; }
    if (this.gameOverWaitingTimeMs > 0) {
      this.gameOverWaitingTimeMs -= (int)gameInfo.getLastFrameIntervalMs();
    }
    if (this.gameOverWaitingTimeMs <= 2000) {
      getPacman(1).setViewFactor(1.0);
      getPacman(2).setViewFactor(1.0);
    }
    if (this.gameOverWaitingTimeMs <= 1000) {
      this.showGameOverBanner = true;
    }
  }

  @Override
  public void update() {
    if (!isGameOver()) { return; }
    backgroundMusicPlayer.mute();
    if (this.showGameOverBanner) {
      Label gameOverLabel = (Label)page.getLocalItem("LabelGameOver");
      if (gameOverLabel != null) { gameOverLabel.restore(); }
    }
  }
}
