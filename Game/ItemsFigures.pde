import java.util.Random;

final String imagePathPacman_1_L = "data/Pacman_1_L.png";
PImage imagePacman_1_L;
final String imagePathPacman_1_R = "data/Pacman_1_R.png";
PImage imagePacman_1_R;
final String imagePathPacman_1_U = "data/Pacman_1_U.png";
PImage imagePacman_1_U;
final String imagePathPacman_1_D = "data/Pacman_1_D.png";
PImage imagePacman_1_D;
final String imagePathPacman_2_L = "data/Pacman_2_L.png";
PImage imagePacman_2_L;
final String imagePathPacman_2_R = "data/Pacman_2_R.png";
PImage imagePacman_2_R;
final String imagePathPacman_2_U = "data/Pacman_2_U.png";
PImage imagePacman_2_U;
final String imagePathPacman_2_D = "data/Pacman_2_D.png";
PImage imagePacman_2_D;
final String imagePathGhost_L = "data/Ghost_L.png";
PImage imageGhost_L;
final String imagePathGhost_R = "data/Ghost_R.png";
PImage imageGhost_R;

void loadResourcesForFigures() {
  imagePacman_1_L = loadImage(imagePathPacman_1_L);
  imagePacman_1_R = loadImage(imagePathPacman_1_R);
  imagePacman_1_U = loadImage(imagePathPacman_1_U);
  imagePacman_1_D = loadImage(imagePathPacman_1_D);
  imagePacman_2_L = loadImage(imagePathPacman_2_L);
  imagePacman_2_R = loadImage(imagePathPacman_2_R);
  imagePacman_2_U = loadImage(imagePathPacman_2_U);
  imagePacman_2_D = loadImage(imagePathPacman_2_D);
  imageGhost_L = loadImage(imagePathGhost_L);
  imageGhost_R = loadImage(imagePathGhost_R);
}


// If figures lose all its HP, it will lose one life,
// and will refresh its HP to `maxHp` if it has remaining lives.
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
  public Figure decLives(int dec, Object cause) { // `cause`: what has caused the figure to lose live?
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
  public Figure decHp(int dec, Object cause) { // `cause`: what has caused the figure to lose hp?
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
final float ghostRestoreTimeS = 12.0;

public class Ghost extends Figure {
  private boolean attracted;

  private Timer changeDirectionTimer;
  private PImage img;

  public Ghost() {
    super(itemTypeGhost + itemCountGhost++, 2.0 * CHARACTER_SIZE, 2.0 * CHARACTER_SIZE);
    setSpeed(defaultGhostSpeed);
    refreshHp(3);
    setLayer(2);
    startMoving();
    this.img = imageGhost_R;
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setBoolean("attracted", this.attracted);
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    this.attracted = json.getBoolean("attracted");
  }

  @Override
  public void evolve() {
    // Ghost goes randomly, except that if the magnet exists, it will be attracted to the magnet.
    if (this.changeDirectionTimer == null) { randomizeDirection(); }
    this.attracted = false;
    Magnet magnet = (Magnet)page.getSyncItem(itemTypeMagnet);
    if (magnet != null && !magnet.isDiscarded()) {
      setDirectionTowards(magnet);
      this.attracted = true;
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
    if (cause instanceof Bullet) {
      Bullet bullet = (Bullet)cause;
      getPacman(bullet.getOwner()).incScore(5);
    }
    incLives(1);
    refreshHp();
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
    // If ghost is attracted to the magnet,
    // it won't change its facing(image) according to moving direction.
    if (this.attracted) { return this.img; }
    if (this.getDirection() == UPWARD || this.getDirection() == RIGHTWARD) {
      this.img = imageGhost_R;
    } else {
      this.img = imageGhost_L;
    }
    return this.img;
  }
}


final String itemTypePacman = "Pacman";
final float defaultPacmanSpeed = 90.0;
final float pacmanIncBulletDurationS = 1.5;
final int pacmanBulletsMax = 20;

public class Pacman extends Figure {
  private int playerId; // Valid values: 1, 2
  private int score;
  private boolean ableToFire;
  private int numBullets;
  private float viewFactor;
  private int controlledByOpponent;
  private int frozen;
  private String buffDesc;

  private Timer loadBulletTimer;

  public Pacman(int playerId) {
    super(itemTypePacman + playerId, 2.51 * CHARACTER_SIZE, 2.51 * CHARACTER_SIZE);
    this.playerId = playerId;
    enableFire();
    // For online version, players only has a view of 40%x40% of the whole map.
    // And even this portion will be further limited by ViewShader.
    setViewFactor(0.4);
    setLayer(1);
    setSpeed(defaultPacmanSpeed);
    setLives(3);
    refreshHp(3);
    buffDesc = "";
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setInt("playerId", getPlayerId());
    json.setInt("score", getScore());
    json.setBoolean("ableToFire", isAbleToFire());
    json.setInt("numBullets", getNumberOfBullets());
    json.setFloat("viewFactor", getViewFactor());
    json.setInt("controlledByOpponent", getControlledByOpponent());
    json.setInt("frozen", this.frozen);
    json.setString("buffDesc", getBuffDesc());
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
    setViewFactor(json.getFloat("viewFactor"));
    setControlledByOpponent(json.getInt("controlledByOpponent"));
    this.frozen = json.getInt("frozen");
    setBuffDesc(json.getString("buffDesc"));
  }
  
  public int getPlayerId() { return this.playerId; }
  
  public boolean isControlledByOpponent() { return 0 < getControlledByOpponent(); }
  public int getControlledByOpponent() { return this.controlledByOpponent; }
  public void setControlledByOpponent(int controlled) {
    this.controlledByOpponent = controlled;
  }

  public void setFrozen(int frozen) {
    this.frozen = frozen;
    if (this.frozen > 0) {
      stopMoving();
    }
  }
  public int getFrozen(){ return this.frozen; }

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
    GameState gameState = (GameState)page.getSyncItem("GameState");
    gameState.gameOver();
  }

  public int getScore() { return this.score; }

  public void incScore(int increment){
    this.score += increment;
  }
  
  public void setBuffDesc(String desc) { this.buffDesc = desc; }
  public String getBuffDesc() { return this.buffDesc; }

  public boolean isAbleToFire() { return this.ableToFire; }
  public Pacman enableFire() { this.ableToFire = true; return this; }
  public Pacman disableFire() { this.ableToFire = false; return this; }

  public int getNumberOfBullets() { return this.numBullets; }
  public void incBullet(int inc) { this.numBullets += inc; }
  public void decBullet(int dec) { this.numBullets -= dec; }

  // Generate a bullet.
  public void fire() {
    if (!isAbleToFire()) { return; }
    if (getNumberOfBullets() <= 0) { return; }
    Bullet bullet = new Bullet(getPlayerId());
    bullet.setDirection(getDirection());
    switch (getDirection()) {
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

  public float getViewFactor() { return this.viewFactor; }
  public Pacman setViewFactor(float viewFactor) { this.viewFactor = viewFactor; return this; }

  @Override
  public void evolve() {
    if (this.loadBulletTimer == null) {
      this.loadBulletTimer = new Timer(0.0, pacmanIncBulletDurationS, () -> {
        if (getNumberOfBullets() < pacmanBulletsMax) { incBullet(1); }
      });
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
    if (this.frozen > 0) { return false; }
    if (isControlledByOpponent()) { return getPlayerId() != 1; }
    else { return getPlayerId() == 1; }
  }
  public boolean usingKeySetB() { // Arrows 0
    if (this.frozen > 0) { return false; }
    if (isControlledByOpponent()) { return getPlayerId() != 2; }
    else { return  getPlayerId() == 2; }
  }

  // For online version, pacman 1 is controlled by key events from server host.
  // pacman 2 is controlled by key events from client host.
  public boolean acceptKeyboardEvent(KeyboardEvent e) {
    if (gameInfo.isSingleHost()) { return true; }
    if (isControlledByOpponent()) { return e.getHostId() != getPlayerId(); }
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
  public void update() { // Update corresponding local widgets according to the state of this pacman.
    Label scoreLabel = (Label)page.getLocalItem("Score" + getPlayerId());
    if (scoreLabel != null) { scoreLabel.setText(String.valueOf(getScore())); }

    Label bulletNumber = (Label)page.getLocalItem("BulletNumber" + getPlayerId());
    if (bulletNumber != null) {
      bulletNumber.setText(String.valueOf(getNumberOfBullets()));
      if (getNumberOfBullets() <= 0) {
        bulletNumber.setTextColor(color(255, 0, 0)).setTextFont(fontMinecraft);
      } else {
        if (getPlayerId() == 1){
          bulletNumber.setTextColor(textColorDefault).setTextFont(fontSFPro);
        } else {
          bulletNumber.setTextColor((color(224, 223, 224))).setTextFont(fontSFPro);
        }
      }
    }

    updateHealthWidgets();
    updateBuffLabel();
  }

  private void updateHealthWidgets() {
    for (int i = 1; i <= 3; ++i) {
      RectArea heart = (RectArea)page.getLocalItem("Heart_" + getPlayerId() + "_" + i);
      if (heart == null) { continue; }
      if (i < getLives()) { heart.setImage(imageHeart3); continue; }
      if (getLives() < i) { heart.setImage(imageHeart0); continue; }
      if (getHp() <= 1) {
        heart.setImage(imageHeart1);
      } else if (getHp() == 2) {
        heart.setImage(imageHeart2);
      } else {
        heart.setImage(imageHeart3);
      }
    }
  }

  private void updateBuffLabel() {
    Label buffLabel = (Label)page.getLocalItem("BuffDesc" + getPlayerId());
    if (buffLabel == null) { return; }
    if (getPlayerId() == 1){
       buffLabel.setText("-").setTextFont(fontSFBold).setTextColor(textColorDefault);
    } else {
      buffLabel.setText("-").setTextFont(fontSFBold).setTextColor((color(224, 223, 224)));
    }
    String buffDesc = getBuffDesc();
    if (buffDesc == null || buffDesc.length() <= 0) { return; }
    char type = 0;
    int pos = 0;
    while (pos < buffDesc.length()) {
      type = buffDesc.charAt(pos);
      if (type == '+' || type == '-') { break; }
      ++pos;
    }
    if (type != '+' && type != '-') { return; }
    buffLabel.setText(buffDesc.substring(pos + 1));
    if (type == '+') {
      buffLabel.setTextColor(color(0, 0, 255));
    } else {
      buffLabel.setTextColor(color(255, 0, 0));
    }
  }

  public PImage getImage() {
    if (this.playerId == 1) {
      switch (getDirection()) {
        case LEFTWARD: return imagePacman_1_L;
        case RIGHTWARD: return imagePacman_1_R;
        case UPWARD: return imagePacman_1_U;
        default: return imagePacman_1_D;
      }
    }
    switch (getDirection()) {
      case LEFTWARD: return imagePacman_2_L;
      case RIGHTWARD: return imagePacman_2_R;
      case UPWARD: return imagePacman_2_U;
      default: return imagePacman_2_D;
    }
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
