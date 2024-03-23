import java.util.Random;

final String imagePathPacman = "data/Coin.png";
PImage imagePacman;
final String imagePathGhost = "data/Ghost.jpg";
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

// Ghost class
public class Ghost extends Figure {
    public Ghost(float w, float h) {
        super(itemTypeGhost + itemCountGhost++, w, h);
        setSpeed(50.0); // set Ghost speed
        refreshHp(3);
        setLayer(1);
        randomizeDirection();
        startMoving();
    }
    
    @Override
    public void evolve() {
      if (random(35) < 1.0) {
        // probability of changing direction on each call
        randomizeDirection();
      }
      super.evolve(); // keep moving
    }
    
  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Bullet) {
      decHp(1);
    }
  }
  
    private void randomizeDirection() {
      switch ((int)random(4)) {
        case 0: { setDirection(UPWARD); break; }
        case 1: { setDirection(RIGHTWARD); break; }
        case 2: { setDirection(DOWNWARD); break; }
        case 3: { setDirection(LEFTWARD); break; }
      }
    }

    @Override
    public PImage getImage() {
        return imageGhost;
    }
}


final String itemTypePacman = "Pacman";

public class Pacman extends Figure {
  private int playerId;
  private int score;

  public Pacman(int playerId, float w, float h) {
    super(itemTypePacman + playerId, w, h);
    this.playerId = playerId;
    setSpeed(100.0);
    refreshHp(3);
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
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Coin){
      incScore(1);
    } else if (item instanceof Bullet) {
      decHp(1);
    } else if (item instanceof Wall) {
      tryStepbackFrom(item);
    } else if (item instanceof Ghost) {
      decLives(1);
    }
  }
  
  @Override
  public void onKeyboardEvent(KeyboardEvent e) {
    if (e instanceof KeyPressedEvent) {
      onKeyPressedEvent((KeyPressedEvent)e);
    } else if (e instanceof KeyReleasedEvent) {
      onKeyReleasedEvent((KeyReleasedEvent)e);
    }
  }

  public void onKeyPressedEvent(KeyPressedEvent e) {
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

  public void onKeyReleasedEvent(KeyReleasedEvent e) {
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
