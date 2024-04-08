import java.util.Random;

final String imagePathPacman = "data/Coin.png";
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

  public Figure decLives(int dec) {
    setLives(getLives() - dec);
    if (getLives() == 0) {
      discard();
    } else {
      refreshHp();
    }
    return this;
  }

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

  public Figure decHp(int dec) {
    setHp(getHp() - dec);
    if (getHp() <= 0) {
      decLives(1);
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
  }

  @Override
  public void evolve() {
    ArrayList<SynchronizedItem> magnets = page.getSyncItemsByNameAndCount(itemTypeMagnet, itemCountMagnet);
    if (magnets != null && magnets.size() != 0) {
      for (SynchronizedItem magnet : magnets) {
        if (!magnet.isDiscarded()) {
          setDirectionTowards(magnet.getX(), magnet.getY());
          break;
        }
      }
    } else {
      if (!isMoving()) {
        randomizeDirection();
      }
    }
    startMoving();
    super.evolve();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Bullet) {
      decHp(1);
    }
  }

  @Override
  public void onStepback(Item target) { randomizeDirection(); }

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
  
  public void setDirectionTowards(float targetX, float targetY) {
  
    float deltaX = targetX - getX();
    float deltaY = targetY - getY();
  
    if (Math.abs(deltaX) > Math.abs(deltaY)) {
  
      if (deltaX > 0) {
        setDirection(RIGHTWARD);
      } else {
        setDirection(LEFTWARD);
      }
    } else {
      if (deltaY > 0) {
        setDirection(DOWNWARD);
      } else {
        setDirection(UPWARD);
      }
    }
  }

  @Override
  public Item discard() {
    stopMoving();
    if (this.changeDirectionTimer != null) { this.changeDirectionTimer.destroy(); }
    return super.discard();
  }

  @Override
  public PImage getImage() {
    return imageGhost;
  }
}


final String itemTypePacman = "Pacman";

public class Pacman extends Figure {
  private int playerId; // Valid values: 1, 2
  private int score;
  private boolean isControlledByOpponent = false;
  private boolean isFrozen = false;

  public Pacman(int playerId) {
    super(itemTypePacman + playerId, 1.8 * CHARACTER_SIZE, 1.8 * CHARACTER_SIZE);
    this.playerId = playerId;
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
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    this.playerId = json.getInt("playerId");
    this.score = json.getInt("score");
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
  public Pacman decLives(int dec) {
    super.decLives(dec);
    if (getLives() <= 0) {
      PlayPage playPage = (PlayPage)page;
      playPage.gameOver();
    } else {
      SynchronizedItem shelter = page.getSyncItem(itemTypePacmanShelter + getPlayerId());
      setCenterX(shelter.getCenterX());
      setCenterY(shelter.getCenterY());
    }
    return this;
  }

  public int getScore() { return this.score; }

  public void incScore(int increment){
    this.score += increment;
  }

  public void fire() {
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
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Coin){
      incScore(1);
    } else if (item instanceof Bullet) {
      Bullet bullet = (Bullet)item;
      if (!bullet.isFiredBy(this)) { decHp(1); }
    } else if (item instanceof Wall) {
      tryStepbackFrom(item);
    } else if (item instanceof Pacman) {
      tryStepbackFrom(item);
    } else if (item instanceof Ghost) {
      decLives(1);
    }
  }

  public boolean usingKeySetA() { // W A S D Space
    if (isFrozen){return false;}
    if (gameInfo.isSingleHost() && getIsControlledByOpponent()) {
      return getPlayerId() != 1;
    }
    return getPlayerId() == 1;
  }
  public boolean usingKeySetB() { // Arrows 0
    if (isFrozen){return false;}
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
