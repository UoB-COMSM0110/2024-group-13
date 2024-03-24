import java.util.Comparator;

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
  public float getW() { return this.w; }
  public float getH() { return this.h; }
  public float getX() { return this.x; }
  public float getY() { return this.y; }
  public int getFacing() { return facing; }
  public int getLayer() { return layer; }
  public boolean isDiscarded(){ return this.discarded; }

  public Item setLeftX(float x) { return setX(x); }
  public Item setRightX(float x) { return setX(x - getW()); }
  public Item setTopY(float y) { return setY(y); }
  public Item setBottomY(float y) { return setY(y - getH()); }
  public Item setCenterX(float x) { return setX(x - getW() / 2.0); }
  public Item setCenterY(float y) { return setY(y - getH() / 2.0); }

  public float getLeftX() { return getX(); }
  public float getRightX() { return getX() + getW(); }
  public float getTopY() { return getY(); }
  public float getBottomY() { return getY() + getH(); }
  public float getCenterX() { return getX() + getW() / 2.0; }
  public float getCenterY() { return getY() + getH() / 2.0; }

  public void onEvents(ArrayList<Event> events) {
    events.forEach((e) -> { onEvent(e); });
  }

  // Deals with events.
  public void onEvent(Event e) {
    if (e instanceof MouseEvent) { onMouseEvent((MouseEvent)e); }
    else if (e instanceof KeyboardEvent) { onKeyboardEvent((KeyboardEvent)e); }
    else {}
  }
  public void onMouseEvent(MouseEvent e) {}
  public void onKeyboardEvent(KeyboardEvent e) {}

  // Whether the mouse cursor is over the item when the event happened.
  public boolean isMouseEventRelated(MouseEvent e) {
    return getLeftX() < e.getX() && e.getX() < getRightX()
      && getTopY() < e.getY() && e.getY() < getBottomY();
  }

  // Update status for each game frame.
  // Generally the update here won't affect game logic,
  // but only affects visual effects, human-game interactions, etc.
  // This method can interact with other items.
  public void update() {}

  public void delete() { page.deleteItem(getName()); System.out.println("delete " + getName()); }

  public PImage getImage() { return null; }

  public void draw() { draw(getX(), getY(), getW(), getH()); }

  public void draw(float x, float y, float w, float h) {
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
  public void evolve() {}

  // Called when two sync items collide with each other.
  public void onCollisionWith(SynchronizedItem item) {}

  // Serialize item status for transmission through network.
  public String serialize() { return ""; }

  // Sync items use sync coordiantes.
  // Need to transform sync coordinates into local coordinates before drawing.
  @Override
  public void draw() {
    draw(getLocalX(), getLocalY(), getLocalW(), getLocalH());
  }

  public float getLocalX() {
    return gameInfo.getMapOffsetX() + getX() * gameInfo.getMapScaleX();
  }
  public float getLocalY() {
    return gameInfo.getMapOffsetY() + getY() * gameInfo.getMapScaleY();
  }
  public float getLocalW() { return getW() * gameInfo.getMapScaleX(); }
  public float getLocalH() { return getH() * gameInfo.getMapScaleY(); }
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
  }

  public MovableItem setSpeed(float speed) { this.speed = max(speed, 0.0); return this; }
  public MovableItem setDirection(int direction) {
    this.direction = direction;
    return this;
  }
  public MovableItem startMoving() { this.moving = true; return this; }
  public MovableItem stopMoving() { this.moving = false; return this; }
  
  public float getSpeed() { return this.speed; }
  public int getDirection() { return this.direction; }
  public boolean isMoving() { return this.moving; }
  
  @Override
  public void evolve() {
    if (isMoving()) {
      move();
    }
  }

  private MovableItem moveX(float dx) { setX(getX() + dx); return this; }
  private MovableItem moveY(float dy) { setY(getY() + dy); return this; }

  private void saveRefPoint() {
    this.refX = getX();
    this.refY = getY();
  }

  public void move() {
    saveRefPoint();
    float distance = speed * gameInfo.getLastFrameIntervalS();
    doMovement(distance);
  }

  public boolean tryStepbackFrom(Item target) {
    float backMovement = getPenetrationDepthOf(target);
    float prevMovement = getMovementFromRefPoint();
    if (backMovement < 0 || backMovement > prevMovement) { return false; }
    backMovement = min(backMovement + epsilon, prevMovement);
    doMovement(-backMovement);
    return true;
  }

  private float getPenetrationDepthOf(Item target) {
    switch (getDirection()) {
      case UPWARD: return target.getBottomY() - getTopY();
      case RIGHTWARD: return -(target.getLeftX() - getRightX());
      case DOWNWARD: return -(target.getTopY() - getBottomY());
      case LEFTWARD: return target.getRightX() - getLeftX();
    }
    return 0.0;
  }

  private float getMovementFromRefPoint() {
    switch (getDirection()) {
      case UPWARD: return -(getY() - this.refY);
      case RIGHTWARD: return getX() - this.refX;
      case DOWNWARD: return getY() - this.refY;
      case LEFTWARD: return -(getX() - this.refX);
    }
    return 0.0;
  }

  private void doMovement(float distance) {
    switch (getDirection()) {
      case UPWARD: { moveY(-distance); break; }
      case RIGHTWARD: { moveX(distance); break; }
      case DOWNWARD: { moveY(distance); break; }
      case LEFTWARD: { moveX(-distance); break; }
    }
  }
}
