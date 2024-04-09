import java.util.Random;

final String imagePathPacman = "data/Pacman.png";
PImage imagePacman;
final String imagePathGhost = "data/Ghost.png";
PImage imageGhost;

void loadResoucesForFigures() {
  imagePacman = loadImage(imagePathPacman);
  imageGhost = loadImage(imagePathGhost);
}


public abstract class Figure extends MovableItem {
  private int lives;
  private int maxHp;
  private int hp;

  public Figure(String name, float w, float h) {
    super(name, w, h);
    setLives(1);
    refreshHp(1);
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setInt("lives", getLives());
    json.setInt("maxHp", getMaxHp());
    json.setInt("hp", getHp());
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    setLives(json.getInt("lives"));
    setMaxHp(json.getInt("maxHp"));
    setHp(json.getInt("hp"));
  }
  
  public int getLives() { return this.lives; }

  public Figure setLives(int lives) {
    this.lives = lives >= 0 ? lives : 0;
    return this;
  }

  public Figure incLives(int inc) { return setLives(getLives() + inc); }

  public Figure decLives(int dec) { return decLives(dec, null); }
  public Figure decLives(int dec, Object cause) {
    setLives(getLives() - dec);
    if (getLives() <= 0) {
      onLostAllLives(cause);
    } else {
      refreshHp();
      onLostLife(cause);
    }
    return this;
  }

  public void onLostLife(Object cause) {}
  public void onLostAllLives(Object cause) {}

  public int getMaxHp() { return this.maxHp; }
  public Figure setMaxHp(int maxHp) {
    this.maxHp = maxHp > 0 ? maxHp : 0;
    return this;
  }

  public Figure refreshHp() { return setHp(getMaxHp()); }
  public Figure refreshHp(int maxHp) { return setMaxHp(maxHp).refreshHp(); }

  public int getHp() { return this.hp; }

  public Figure setHp(int hp) {
    if (hp < 0) { hp = 0; }
    if (getMaxHp() > 0 && hp > getMaxHp()) {
      hp = getMaxHp();
    }
    this.hp = hp;
    return this;
  }

  public Figure incHp(int inc) { return setHp(getHp() + inc); }

  public Figure decHp(int dec) { return decHp(dec, null); }
  public Figure decHp(int dec, Object cause) {
    setHp(getHp() - dec);
    if (getHp() <= 0) {
      decLives(1, cause);
    }
    return this;
  }
}


final String itemTypeGhost = "Ghost";
int itemCountGhost;
final float defaultGhostSpeed = 50.0;

public class Ghost extends Figure {
  private Timer changeDirectionTimer;

  public Ghost() {
    super(itemTypeGhost + itemCountGhost++, 2.0 * CHARACTER_SIZE, 2.0 * CHARACTER_SIZE);
    setSpeed(defaultGhostSpeed);
    refreshHp(3);
    setLayer(2);
    startMoving();
  }

  @Override
  public void evolve() {
    if (this.changeDirectionTimer == null) { randomizeDirection(); }
    Magnet magnet = (Magnet)page.getSyncItem(itemTypeMagnet);
    if (magnet != null && !magnet.isDiscarded()) {
      setDirectionTowards(magnet);
    }
    super.evolve();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Bullet) {
      decHp(1, item);
    }
  }

  @Override
  public void onStepback(Item target) { randomizeDirection(); }

  @Override
  public void onLostAllLives(Object cause) {
    discardFor(ghostRestoreTimeS);
  }

  private void randomizeDirection() {
    switch ((int)random(4)) {
      case 0: { setDirection(UPWARD); break; }
      case 1: { setDirection(RIGHTWARD); break; }
      case 2: { setDirection(DOWNWARD); break; }
      case 3: { setDirection(LEFTWARD); break; }
    }
    if (this.changeDirectionTimer != null) { this.changeDirectionTimer.destroy(); }
    float timeS = 1.0 + random(4.0); // [1.0s, 5.0s)
    this.changeDirectionTimer = new OneOffTimer(timeS, () -> { randomizeDirection(); });
    page.addTimer(this.changeDirectionTimer);
  }
  
  @Override
  public PImage getImage() {
    return imageGhost;
  }
}


final String itemTypePacman = "Pacman";
final float pacmanIncBulletDurationS = 2.0;
final float ghostRestoreTimeS = 12.0;

public class Pacman extends Figure {
  private int playerId; // Valid values: 1, 2
  private int score;
  private boolean ableToFire;
  private int numBullets;
  private boolean isControlledByOpponent = false;
  private boolean isFrozen = false;

  private Timer loadBulletTimer;

  public Pacman(int playerId) {
    super(itemTypePacman + playerId, 1.8 * CHARACTER_SIZE, 1.8 * CHARACTER_SIZE);
    this.playerId = playerId;
    enableFire();
    setLayer(1);
    setSpeed(100.0);
    setLives(3);
    refreshHp(3);
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setInt("playerId", getPlayerId());
    json.setInt("score", getScore());
    json.setBoolean("ableToFire", isAbleToFire());
    json.setInt("numBullets", getNumberOfBullets());
    json.setBoolean("isControlledByOpponent", getIsControlledByOpponent());
    json.setBoolean("isFrozen", this.isFrozen);
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    this.playerId = json.getInt("playerId");
    this.score = json.getInt("score");
    if (json.getBoolean("ableToFire")) { enableFire(); }
    else { disableFire(); }
    this.numBullets = json.getInt("numBullets");
    setIsControlledByOpponent(json.getBoolean("isControlledByOpponent"));
    this.isFrozen = json.getBoolean("isFrozen");
  }
  
  public int getPlayerId() { return this.playerId; }
  
  public boolean getIsControlledByOpponent() { return this.isControlledByOpponent; }

  public void setIsControlledByOpponent(boolean controlled) {
    this.isControlledByOpponent = controlled;
  }

  public void freeze() {
    this.isFrozen = true;
    stopMoving();
  }

  public void unfreeze(){
    this.isFrozen = false;
  }

  @Override
  public void onLostLife(Object cause) {
    if (cause instanceof Bullet) {
      this.getOpponent().incScore(20);
    }
    SynchronizedItem shelter = page.getSyncItem(itemTypePacmanShelter + getPlayerId());
    setCenterX(shelter.getCenterX());
    setCenterY(shelter.getCenterY());
  }
  @Override
  public void onLostAllLives(Object cause) {
    if (cause instanceof Bullet) {
      this.getOpponent().incScore(50);
    }
    PlayPage playPage = (PlayPage)page;
    playPage.gameOver();
  }

  public int getScore() { return this.score; }

  public void incScore(int increment){
    this.score += increment;
  }

  public boolean isAbleToFire() { return this.ableToFire; }
  public Pacman enableFire() { this.ableToFire = true; return this; }
  public Pacman disableFire() { this.ableToFire = false; return this; }

  public int getNumberOfBullets() { return this.numBullets; }
  public void incBullet(int inc) { this.numBullets += inc; }
  public void decBullet(int dec) { this.numBullets -= dec; }

  public void fire() {
    if (!isAbleToFire()) { return; }
    if (getNumberOfBullets() <= 0) { return; }
    Bullet bullet = new Bullet(getPlayerId());
    bullet.setDirection(getFacing());
    switch (getFacing()) {
      case UPWARD: { bullet.setCenterX(getCenterX()).setBottomY(getTopY() - epsilon); break; }
      case RIGHTWARD: { bullet.setLeftX(getRightX() + epsilon).setCenterY(getCenterY()); break; }
      case DOWNWARD: { bullet.setCenterX(getCenterX()).setTopY(getBottomY() + epsilon); break; }
      case LEFTWARD: { bullet.setRightX(getLeftX() - epsilon).setCenterY(getCenterY()); break; }
    }
    bullet.setSpeed(getSpeed());
    page.addSyncItem(bullet);
    decBullet(1);
    disableFire();
  }

  @Override
  public void evolve() {
    if (this.loadBulletTimer == null) {
      this.loadBulletTimer = new Timer(0.0, pacmanIncBulletDurationS, () -> { incBullet(1); });
      page.addTimer(this.loadBulletTimer);
    }
    super.evolve();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Coin){
      incScore(1);
    } else if (item instanceof Bullet) {
      Bullet bullet = (Bullet)item;
      if (bullet.isFiredBy(this)) { return; }
      decHp(1, bullet);
    } else if (item instanceof Wall) {
      tryStepbackFrom(item);
    } else if (item instanceof Pacman) {
      tryStepbackFrom(item);
    } else if (item instanceof Ghost) {
      decLives(1, item);
    }
  }

  public Pacman getOpponent() {
    return getPacmanOpponent(this);
  }

  public boolean usingKeySetA() { // W A S D Space
    if (this.isFrozen){return false;}
    if (gameInfo.isSingleHost() && getIsControlledByOpponent()) {
      return getPlayerId() != 1;
    }
    return getPlayerId() == 1;
  }
  public boolean usingKeySetB() { // Arrows 0
    if (this.isFrozen){return false;}
    if (gameInfo.isSingleHost() && getIsControlledByOpponent()) {
      return getPlayerId() != 2;
    }
    return  getPlayerId() == 2;
  }

  public boolean acceptKeyboardEvent(KeyboardEvent e) {
    if (gameInfo.isSingleHost()) { return true; }
    if (getIsControlledByOpponent()) { return e.getHostId() != getPlayerId(); }
    return e.getHostId() == getPlayerId();
  }

  @Override
  public void onKeyboardEvent(KeyboardEvent e) {
    if (!acceptKeyboardEvent(e)) { return; }
    if (e instanceof KeyPressedEvent) {
      onKeyPressedEvent((KeyPressedEvent)e);
    } else if (e instanceof KeyReleasedEvent) {
      onKeyReleasedEvent((KeyReleasedEvent)e);
    }
  }

  public void onKeyPressedEvent(KeyPressedEvent e) {
    if (e.getKey() == ' ' && usingKeySetA()) { fire(); return; }
    if (e.getKey() == '0' && usingKeySetB()) { fire(); return; }
    Integer direction = getDirectionFromKeyEvent(e);
    if (direction != null) {
      setFacing(direction.intValue());
      setDirection(direction.intValue());
      startMoving();
      return;
    }
  }

  public void onKeyReleasedEvent(KeyReleasedEvent e) {
    if (e.getKey() == ' ' && usingKeySetA()) { enableFire(); return; }
    if (e.getKey() == '0' && usingKeySetB()) { enableFire(); return; }
    Integer direction = getDirectionFromKeyEvent(e);
    if (direction == null) { return; }
    if (getDirection() == direction.intValue()) { stopMoving(); }
  }

  private Integer getDirectionFromKeyEvent(KeyboardEvent e) {
    if (e.getKey() == CODED) {
      if(!usingKeySetB()) { return null; }
      switch (e.getKeyCode()) {
        case UP: return UPWARD;
        case LEFT: return LEFTWARD;
        case DOWN: return DOWNWARD;
        case RIGHT: return RIGHTWARD;
        default: return null;
      }
    }
    if(!usingKeySetA()) { return null; }
    switch (e.getKey()) {
      case 'w': case 'W': return UPWARD;
      case 'a': case 'A': return LEFTWARD;
      case 's': case 'S': return DOWNWARD;
      case 'd': case 'D': return RIGHTWARD;
      default: return null;
    }
  }

  @Override
  void update() {
    Label scoreLabel = (Label)page.getLocalItem("Score" + getPlayerId());
    if (scoreLabel != null) { scoreLabel.setText(String.valueOf(getScore())); }
    Label livesLabel = (Label)page.getLocalItem("Lives" + getPlayerId());
    if (livesLabel != null) { livesLabel.setText(String.valueOf(getLives())); }
    // gameInfo.setMapScaleX(5.0);
    // gameInfo.setMapScaleY(5.0);
    // gameInfo.setMapOffsetX(- getX() * 5.0 + 100);
    // gameInfo.setMapOffsetY(- getY() * 5.0 + 100 + 80);
  }

  public PImage getImage() {
    return imagePacman;
  }
}

public Pacman getPacmanOpponent(Pacman pacman) {
  return getPacmanOpponent(pacman.getPlayerId());
}
public Pacman getPacmanOpponent(int playerId) {
  int opponentId = (playerId == 1) ? 2 : 1;
  return getPacman(opponentId);
}
public Pacman getPacman(int playerId) {
  return (Pacman)page.getSyncItem(itemTypePacman + playerId);
}
