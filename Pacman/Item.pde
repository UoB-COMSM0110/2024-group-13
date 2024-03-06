import java.util.Comparator;

// Using degree to represent the facing of an item.
static final int UPWARD = 0;
static final int RIGHTWARD = 90;
static final int DOWNWARD = 180;
static final int LEFTWARD = 270;


// Every thing shown in the game is an Item: bricks, buttons, power-ups, etc.
public class Item {
  private String name;
  private float x, y; // Position of item top-left corner.
  public float w, h; // Item size.
  private boolean elliptic;
  private int facing;
  public int layer; // Item layer decides its drawing order.
  private boolean discarded;

  public Item(String name, float x, float y) {
    this.name = name;
    this.x = x;
    this.y = y;
  }
  
  public Item setW(float w) { this.w = w; return this; }
  public Item setH(float h) { this.h = h; return this; }
  
  public void setX(float x) { this.x = x; }
  public void setY(float y) { this.y = y; }
  
  public float getX() { return x; }
  public float getY() { return y; }
  public float getW() { return w; }
  public float getH() { return h; }
  public int getFacing() { return facing; }
  public String getName() { return name; }
  public int getLayer() { return layer; }

  public void onEvents(GameInfo gInfo, ArrayList<Event> events) {
    events.forEach((e) -> { onEvent(gInfo, e); });
  }

  // Deals with events.
  public void onEvent(GameInfo gInfo, Event e) {
    if (e instanceof MouseEvent) {
      onMouseEvent(gInfo, (MouseEvent)e);
    } else if (e instanceof KeyboardEvent) {
      onKeyboardEvent(gInfo, (KeyboardEvent)e);
    } else {
    }
  }

  public void onMouseEvent(GameInfo gInfo, MouseEvent e) {}

  public void onKeyboardEvent(GameInfo gInfo, KeyboardEvent e) {}

  // Update status for each game frame.
  // Generally the update here won't affect game logic,
  // but only visual effects, human-game interactions, etc.
  // This method can interact with other items.
  public void update(GameInfo gInfo, Page page) {}

  public PImage getImage() { return null; }

  public void draw(GameInfo gInfo) {
    PImage img = getImage();
    if (img == null) { return; }
    image(img, x, y, w, h);
  }
}


// Compare items based on its layer.
// Used when deciding drawing order of items.
public class ItemLayerComparator implements Comparator<Item> {
  public int compare(Item i1, Item i2) { return  i1.getLayer() - i2.getLayer(); }
}


// Local items don't need synchronize between two players.
// For example: buttons, labels, etc.
public class LocalItem extends Item {
  public LocalItem(String name, float x, float y) {
    super(name, x, y);
  }
}


// Synchronized items need synchronize between two players.
// For example: figures, bricks, bullets, etc.
public class SynchronizedItem extends Item {
  public SynchronizedItem(String name, float x, float y) {
    super(name, x, y);
  }

  // Additional method for sync items to update status.
  // Mainly update status which affects game logic, e.g., movement of figures.
  public void evolve(GameInfo gInfo) {}

  // Called when two sync items collide with each other.
  public void onCollisionWith(GameInfo gInfo, SynchronizedItem item) {}

  // Serialize item status for transmission through network.
  public String serialize() { return ""; }

  // Sync items use sync coordiantes.
  // Need to transform sync coordinates into local coordinates before drawing.
  @Override
  public void draw(GameInfo gInfo) {
    PImage img = getImage();
    if (img == null) { return; }
    float actualX = getX() * gInfo.getSyncCoordScaleX() + gInfo.getSyncCoordOffsetX();
    float actualY = getY() * gInfo.getSyncCoordScaleY() + gInfo.getSyncCoordOffsetY();
    float actualW = getW() * gInfo.getSyncCoordScaleX();
    float actualH = getH() * gInfo.getSyncCoordScaleY();
    image(img, actualX, actualY, actualW, actualH);
  }
}


// Sync items that can move in the map, e.g., bullets, figures, etc.
public class MovableItem extends SynchronizedItem {
  private float speed;
  private int direction;
  private boolean moving;// Whether the item is moving between two frames.
  
  public MovableItem(String name, float x, float y) {
    super(name, x, y);
  }
  
  public void setSpeed(float speed) { this.speed = speed; }
  public void setDirection(int direction) { this.direction = direction; }
  public void startMoving() { moving = true; }
  public void startMovingUp() { direction = UPWARD; moving = true; }
  public void startMovingRight() { direction = RIGHTWARD; moving = true; }
  public void startMovingDown() { direction = DOWNWARD; moving = true; }
  public void startMovingLeft() { direction = LEFTWARD; moving = true; }
  public void stopMoving() { moving = false; }
  
  public float getSpeed() { return speed; }
  public int getDirection() { return direction; }
  public boolean getMoving() { return moving; }
  
  public void evolve(GameInfo gInfo) { move(); }

  public void move() {
    if (!moving) { return; }
    switch (direction) {
      case UPWARD: {
        float newY = getY() - speed;
        setY(newY);
        break;
      }
      case RIGHTWARD: {
        float newX = getX() + speed;
        setX(newX);
        break;
      }
      case DOWNWARD: {
        float newY = getY() + speed;
        setY(newY);
        break;
      }
      case LEFTWARD: {
        float newX = getX() - speed;
        setX(newX);
        break;
      }
    }
  }
}
