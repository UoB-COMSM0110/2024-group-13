import java.util.Comparator;

// Using degree to represent the facing of an item.
static final int UPWARD = 0;
static final int RIGHTWARD = 90;
static final int DOWNWARD = 180;
static final int LEFTWARD = 270;


// Every thing shown in the game is an Item: bricks, buttons, power-ups, etc.
public class Item {
  private String name;
  private float w, h; // Item size.
  private float x, y; // Position of item top-left corner.
  private boolean elliptic;
  private int facing;
  private int layer; // Item layer decides its drawing order.
  public boolean discarded;

  public Item(String name, float w, float h) {
    this.name = name;
    this.w = w;
    this.h = h;
  }
  
  public Item setW(float w) { this.w = w; return this; }
  public Item setH(float h) { this.h = h; return this; }
  public Item setX(float x) { this.x = x; return this; }
  public Item setY(float y) { this.y = y; return this; }
  public Item setFacing(int facing) { this.facing = facing; return this; }
  public Item setLayer(int layer) { this.layer = layer; return this; }
  
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
  
  public void isDiscarded(){
    return this.discarded;
  }

  public void discard(){
    this.discarded = true;
  }

  public void restore(){
    this.discarded = false;
  }

  public void setScore(int increment) {}
}


// Compare items based on its layer.
// Used when deciding drawing order of items.
public class ItemLayerComparator implements Comparator<Item> {
  public int compare(Item i1, Item i2) { return  i1.getLayer() - i2.getLayer(); }
}


// Local items don't need synchronize between two players.
// For example: buttons, labels, etc.
public class LocalItem extends Item {
  public LocalItem(String name, float w, float h) {
    super(name, w, h);
  }
}


// Synchronized items need synchronize between two players.
// For example: figures, bricks, bullets, etc.
public class SynchronizedItem extends Item {
  public SynchronizedItem(String name, float w, float h) {
    super(name, w, h);
  }

  // Additional method for sync items to update status.
  // Mainly update status which affects game logic, e.g., movement of figures.
  public void evolve(GameInfo gInfo) {}

  // Called when two sync items collide with each other.
  public void onCollisionWith(GameInfo gInfo, SynchronizedItem item) {}

  // Serialize item status for transmission through network.
  public String serialize() { return ""; }

  public void setScore(int increment){}

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

  private float prev_x;
  private float prev_y;
  
  public MovableItem(String name, float w, float h) {
    super(name, w, h);
    speed = 100.0;
  }

  public Item setX(float x) { this.x = x; this.prev_x = x; return this; }
  public Item setY(float y) { this.y = y; this.prev_y = y; return this; }
  
  public MovableItem setSpeed(float speed) {
    this.speed = speed;
    return this;
  }
  public MovableItem setDirection(int direction) {
    this.direction = direction;
    return this;
  }
  public MovableItem startMoving() { moving = true; return this; }
  public MovableItem stopMoving() { moving = false; return this; }
  
  public float getSpeed() { return speed; }
  public int getDirection() { return direction; }
  public boolean getMoving() { return moving; }
  public void setScore(int increment){}
  
  public void evolve(GameInfo gInfo) {
    if (getMoving()) { move(gInfo); }
  }

  public void move(GameInfo gInfo) {
    float distance = speed * gInfo.getLastFrameIntervalMs() / 1000.0;
    this.prev_x = x;
    this.prev_y = y;
    switch (direction) {
      case UPWARD: { this.y -= distance; break; }
      case RIGHTWARD: { this.x += distance; break; }
      case DOWNWARD: { this.y += distance; break; }
      case LEFTWARD: { this.x -= distance; break; }
    }
  }
}
