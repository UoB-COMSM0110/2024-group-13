
final static float SCALE = 10.0/700;


String imagePathBreakableWall = "data/GUI/BreakableBrick.png";
PImage imageBreakableWall;

public class BreakableWall extends SynchronizedItem {
  public int strength;

  public BreakableWall(String name, float x, float y) {
    super(name, x, y);
    strength = 3;
    super.layer = 4;
    if (imageBreakableWall == null ) {
      imageBreakableWall = loadImage(imagePathBreakableWall);
    }
    super.w = imageBreakableWall.width * SCALE;
    super.h = imageBreakableWall.height * SCALE;
  }

  public PImage getImage() {
    return imageBreakableWall;
  }
}


String imagePathIndestructableWall = "data/GUI/IndestructableBrick.png";
PImage imageIndestructableWall;

public class IndestructableWall extends SynchronizedItem {
  public IndestructableWall(String name, float x, float y) {
    super(name, x, y);
    super.layer = 4;
    if (imageIndestructableWall == null ) {
      imageIndestructableWall = loadImage(imagePathIndestructableWall);
    }
    super.w = imageIndestructableWall.width * SCALE;
    super.h = imageIndestructableWall.height * SCALE;
  }

  public PImage getImage() {
    return imageIndestructableWall;
  }
}


String imagePathCoin = "data/GUI/Coin.png";
PImage imageCoin;

public class Coin extends SynchronizedItem {
  public Coin(String name, float x, float y) {
    super(name, x, y);
    super.layer = 1;
    if (imageCoin == null ) {
      imageCoin = loadImage(imagePathCoin);
    }
    super.w = imageCoin.width * SCALE;
    super.h = imageCoin.height * SCALE;
  }

  public PImage getImage() {
    return imageCoin;
  }
}


String imagePathPowerUp = "data/GUI/PowerUp.png";
PImage imagePowerUp;

public class PowerUp extends SynchronizedItem {
  public PowerUp(String name, float x, float y) {
    super(name, x, y);
    super.layer = 1;
    if (imagePowerUp == null ) {
      imagePowerUp = loadImage(imagePathPowerUp);
    }
    super.w = imagePowerUp.width * SCALE;
    super.h = imagePowerUp.height * SCALE;
  }

  public PImage getImage() {
    return imagePowerUp;
  }
}


String imagePathPacmanFigure = "data/GUI/Coin.png";
PImage imagePacmanFigure;

public class PacmanFigure extends MovableItem {
  public PacmanFigure(String name, float x, float y) {
    super(name, x, y);
    super.layer = 1;
    setSpeed(200);
  }

  public PImage getImage() {
    if (imagePacmanFigure == null ) {
      imagePacmanFigure = loadImage(imagePathPacmanFigure);
    }
    return imagePacmanFigure;
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
    switch (e.getKey()) {
      case 'w': case 'W': { startMovingUp(); break; }
      case 'a': case 'A': { startMovingLeft(); break; }
      case 's': case 'S': { startMovingDown(); break; }
      case 'd': case 'D': { startMovingRight(); break; }
    }
    if (e.getKey() == CODED) {
      switch (e.getKeyCode()) {
        case UP: { startMovingUp(); break; }
        case LEFT: { startMovingLeft(); break; }
        case DOWN: { startMovingDown(); break; }
        case RIGHT: { startMovingRight(); break; }
      }
    }
  }

  public void onKeyReleasedEvent(GameInfo gInfo, KeyReleasedEvent e) {
    switch (e.getKey()) {
      case 'w': case 'W': case 'a': case 'A':
      case 's': case 'S': case 'd': case 'D': { stopMoving(); break; }
    }
    if (e.getKey() == CODED) {
      switch (e.getKeyCode()) {
        case UP: case LEFT: case DOWN: case RIGHT: { stopMoving(); break; }
      }
    }
  }
}
