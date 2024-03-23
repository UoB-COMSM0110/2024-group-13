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
  private int facing;
  private int layer; // Item layer decides its drawing order.
  private boolean discarded;

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
  public Item discard() { this.discarded = true; return this; }
  public Item restore() { this.discarded = false; return this; }
  
  public String getName() { return name; }
  public float getW() { return w; }
  public float getH() { return h; }
  public float getX() { return x; }
  public float getY() { return y; }
  public int getFacing() { return facing; }
  public int getLayer() { return layer; }
  public boolean isDiscarded(){ return this.discarded; }

  public void onEvents(GameInfo gInfo, Page page, ArrayList<Event> events) {
    events.forEach((e) -> { onEvent(gInfo, page, e); });
  }

  // Deals with events.
  public void onEvent(GameInfo gInfo, Page page, Event e) {
    if (e instanceof MouseEvent) { onMouseEvent(gInfo, page, (MouseEvent)e); }
    else if (e instanceof KeyboardEvent) { onKeyboardEvent(gInfo, page, (KeyboardEvent)e); }
    else {}
  }
  public void onMouseEvent(GameInfo gInfo, Page page, MouseEvent e) {}
  public void onKeyboardEvent(GameInfo gInfo, Page page, KeyboardEvent e) {}

  // Update status for each game frame.
  // Generally the update here won't affect game logic,
  // but only affects visual effects, human-game interactions, etc.
  // This method can interact with other items.
  public void update(GameInfo gInfo, Page page) {}

  public PImage getImage() { return null; }

  public void draw(GameInfo gInfo) { draw(gInfo, this.x, this.y, this.w, this.h); }

  public void draw(GameInfo gInfo, float x, float y, float w, float h) {
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
  public LocalItem(String name, float w, float h) { super(name, w, h); }
}


// Synchronized items need synchronize between two players.
// For example: figures, bricks, bullets, etc.
public class SynchronizedItem extends Item {
  public SynchronizedItem(String name, float w, float h) { super(name, w, h); }

  // Additional method for sync items to update status.
  // Mainly update status which affects game logic, e.g., movement of figures.
  public void evolve(GameInfo gInfo, Page page) {}

  // Called when two sync items collide with each other.
  public void onCollisionWith(GameInfo gInfo, Page page, SynchronizedItem item, float dx, float dy) {}
  public void onCollisionWith(GameInfo gInfo, Page page, SynchronizedItem item) {}

  // Serialize item status for transmission through network.
  public String serialize() { return ""; }

  // Sync items use sync coordiantes.
  // Need to transform sync coordinates into local coordinates before drawing.
  @Override
  public void draw(GameInfo gInfo) {
    draw(gInfo, getLocalX(gInfo), getLocalY(gInfo), getLocalW(gInfo), getLocalH(gInfo));
  }

  public float getLocalX(GameInfo gInfo) {
    return gInfo.getMapOffsetX() + getX() * gInfo.getMapScaleX();
  }
  public float getLocalY(GameInfo gInfo) {
    return gInfo.getMapOffsetY() + getY() * gInfo.getMapScaleY();
  }
  public float getLocalW(GameInfo gInfo) { return getW() * gInfo.getMapScaleX(); }
  public float getLocalH(GameInfo gInfo) { return getH() * gInfo.getMapScaleY(); }
}


// Sync items that can move in the map, e.g., bullets, figures, etc.
public class MovableItem extends SynchronizedItem {
  private float speed;
  private int direction;
  private boolean moving; // Whether the item is moving between two frames.
  
  private float refX;
  private float refY;
  
  public MovableItem(String name, float w, float h) {
    super(name, w, h);
    speed = 100.0;
  }

  public MovableItem moveX(float dx) { setX(getX() + dx); return this; }
  public MovableItem moveY(float dy) { setY(getY() + dy); return this; }
  public MovableItem setSpeed(float speed) { this.speed = speed; return this; }
  public MovableItem setDirection(int direction) { this.direction = direction; return this; }
  public MovableItem startMoving() { this.moving = true; return this; }
  public MovableItem stopMoving() { this.moving = false; return this; }
  public MovableItem saveRefPoint(float x, float y) {
    this.refX = x;
    this.refY = y;
    return this;
  }
  
  public float getSpeed() { return this.speed; }
  public int getDirection() { return this.direction; }
  public boolean isMoving() { return this.moving; }
  
  @Override
  public void evolve(GameInfo gInfo, Page page) {
    if (isMoving()) {
      saveRefPoint(getX(), getY());
      move(gInfo);
    }
  }

  public void move(GameInfo gInfo) {
    float distance = speed * gInfo.getLastFrameIntervalS();
    switch (direction) {
      case UPWARD: { moveY(-distance); break; }
      case RIGHTWARD: { moveX(distance); break; }
      case DOWNWARD: { moveY(distance); break; }
      case LEFTWARD: { moveX(-distance); break; }
    }
  }
}
