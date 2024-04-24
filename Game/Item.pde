// This file contains base abstract classes for items in the game.
import java.util.Comparator;

static final int UPWARD = 0;
static final int RIGHTWARD = 90;
static final int DOWNWARD = 180;
static final int LEFTWARD = 270;

final float CHARACTER_SIZE = 10.0;


// Every thing shown in the game is an `Item`: bricks, buttons, power-ups, etc.
public abstract class Item {
  private String name;
  private float w, h; // Item size.
  private float x, y; // Position of item top-left corner.
  private int layer; // Item layer decides its drawing order.
  private boolean discarded;

  private String storedStateStr;

  public Item(String name, float w, float h) {
    this.name = name;
    this.w = w;
    this.h = h;
    this.storedStateStr = "";
  }

  public JSONObject getStateJson() {
    JSONObject json = new JSONObject();
    json.setString("class", getClass().getSimpleName());
    json.setString("name", getName());
    json.setFloat("w", getW());
    json.setFloat("h", getH());
    json.setFloat("x", getX());
    json.setFloat("y", getY());
    json.setInt("layer", getLayer());
    json.setBoolean("discarded", isDiscarded());
    return json;
  }
  public void setStateJson(JSONObject json) {
    this.name = json.getString("name");
    setW(json.getFloat("w"));
    setH(json.getFloat("h"));
    setX(json.getFloat("x"));
    setY(json.getFloat("y"));
    setLayer(json.getInt("layer"));
    if (json.getBoolean("discarded")) { discard(); }
    else { restore(); }
  }
  public void storeStateStr(String str) { this.storedStateStr = str; }
  public String getStoredStateStr() { return this.storedStateStr; }
  
  public Item setW(float w) { this.w = w; return this; }
  public Item setH(float h) { this.h = h; return this; }
  public Item setX(float x) { this.x = x; return this; }
  public Item setY(float y) { this.y = y; return this; }
  public Item setLayer(int layer) { this.layer = layer; return this; }
  public Item discard() { this.discarded = true; return this; }
  public Item restore() { this.discarded = false; return this; }
  
  public String getName() { return name; }
  public float getW() { return this.w; }
  public float getH() { return this.h; }
  public float getX() { return this.x; }
  public float getY() { return this.y; }
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

  public void zoom(float ratio) {
    float centerX = getCenterX();
    float centerY = getCenterY();
    float newW = getW() * ratio;
    float newH = getH() * ratio;
    setW(newW).setH(newH).setCenterX(centerX).setCenterY(centerY);
  }

  // Update status for each game frame.
  // Generally the update here won't affect game logic,
  // but only affects visual effects, human-game interactions, etc.
  // This method can interact with other items.
  public void update() {}

  public abstract void delete();

  public PImage getImage() { return null; }

  public void draw() { draw(getX(), getY(), getW(), getH()); }

  public void draw(float x, float y, float w, float h) {
    drawLocally(x, y, w, h);
  }

  public void drawLocally(float x, float y, float w, float h) {
      PImage img = getImage();
      if (img == null) { return; }
      image(img, x, y, w, h);
  }
}


// Compare items based on its layer.
// Used when deciding drawing order of items.
public class ItemLayerComparator implements Comparator<Item> {
  public int compare(Item i1, Item i2) {
    return  i1.getLayer() - i2.getLayer();
  }
}


// Local items don't need synchronize between two players.
// For example: buttons, labels, etc.
public abstract class LocalItem extends Item {
  public LocalItem(String name, float w, float h) { super(name, w, h); }

  @Override
  public final JSONObject getStateJson() { return null; }
  @Override
  public final void setStateJson(JSONObject json) {}

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

  @Override
  public void delete() { page.deleteLocalItem(getName()); }
}


// Synchronized items need synchronize between two players.
// For example: figures, bricks, bullets, etc.
public abstract class SynchronizedItem extends Item {
  public SynchronizedItem(String name, float w, float h) { super(name, w, h); }

  public void onKeyboardEvent(KeyboardEvent e) {}

  // Whether the mouse cursor is over the item when the event happened.
  public boolean isMouseEventRelated(MouseEvent e) {
    return getLeftX() < e.getX() && e.getX() < getRightX()
      && getTopY() < e.getY() && e.getY() < getBottomY();
  }

  // Additional method for sync items to update status.
  // Mainly update status which affects game logic, e.g., movement of figures.
  public void evolve() {}

  public boolean noCollisionCheck() { return isDiscarded(); }

  // Called when two sync items collide with each other.
  public void onCollisionWith(SynchronizedItem target) {}

  public boolean isOverlapWith(SynchronizedItem target) {
    return getLeftX() < target.getRightX() && target.getLeftX() < getRightX() &&
      getTopY() < target.getBottomY() && target.getTopY() < getBottomY();
  }

  // Adapted from Chao's previous code in ItemsFigures.pde
  public int getDirectionOf(SynchronizedItem target) {
    float dx = target.getCenterX() - getCenterX();
    float dy = target.getCenterY() - getCenterY();
    if (Math.abs(dx) > Math.abs(dy)) {
      if (dx > 0) { return RIGHTWARD; }
      else { return LEFTWARD; }
    } else {
      if (dy > 0) { return DOWNWARD; }
      else { return UPWARD; }
    }
  }

  public SynchronizedItem discardFor(float intervalS) {
    discard();
    page.addTimer(new OneOffTimer(intervalS, () -> { restore(); }));
    return this;
  }

  @Override
  public void delete() { page.deleteSyncItem(getName()); }

  // Sync items use sync coordiantes.
  // Need to transform sync coordinates into local coordinates before drawing.
  @Override
  public void draw(float x, float y, float w, float h) {
    float[] localCoord = page.getLocalCoord(x, y, w, h);
    drawLocally(localCoord[0], localCoord[1], localCoord[2], localCoord[3]);
  }
}


// Sync items that can move in the map, e.g., bullets, figures, etc.
public abstract class MovableItem extends SynchronizedItem {
  private float speed;
  private int direction;
  private boolean moving; // Whether the item is moving between two frames.
  
  private float refX;
  private float refY;
  
  public MovableItem(String name, float w, float h) {
    super(name, w, h);
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setFloat("speed", getSpeed());
    json.setInt("direction", getDirection());
    json.setBoolean("moving", isMoving());
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    setSpeed(json.getFloat("speed"));
    setDirection(json.getInt("direction"));
    if (json.getBoolean("moving")) { startMoving(); }
    else { stopMoving(); }
  }

  public MovableItem setSpeed(float speed) {
    this.speed = max(speed, 0.0);
    return this;
  }
  public MovableItem setDirection(int direction) {
    this.direction = direction;
    return this;
  }
  public MovableItem startMoving() { this.moving = true; return this; }
  public MovableItem stopMoving() { this.moving = false; return this; }
  
  public void setDirectionTowards(SynchronizedItem target) {
    setDirection(getDirectionOf(target));
  }

  public float getSpeed() { return this.speed; }
  public int getDirection() { return this.direction; }
  public boolean isMoving() { return this.moving; }
  
  @Override
  public void evolve() {
    if (!isDiscarded() && isMoving()) { move(); }
  }

  private MovableItem moveX(float dx) { setX(getX() + dx); return this; }
  private MovableItem moveY(float dy) { setY(getY() + dy); return this; }

  private void saveRefPoint() {
    this.refX = getX();
    this.refY = getY();
  }

  public void move() {
    saveRefPoint();
    float distance = speed * gameInfo.getLastEvolveIntervalS();
    doMovement(distance);
  }

  // Step back if `this` "moves" into `target`.
  // If `this` overlaps with `target`, not because of the movement of `this`,
  // but because of, e.g., the resizing of `this`, or the movement of `target`,
  // then `this` won't step back.
  //
  // This method seems to be self-consistent,
  // but can't handle collisions induced by resizing.
  public boolean tryStepbackFrom(Item target) {
    float backMovement = getPenetrationDepthOf(target);
    float prevMovement = getMovementFromRefPoint();
    if (backMovement < 0 || backMovement > prevMovement) { return false; }
    backMovement = min(backMovement + epsilon, prevMovement);
    doMovement(-backMovement);
    onStepback(target);
    return true;
  }

  // If `this` overlaps with `target`,
  // then push `this` in the opposite of `direction`.
  //
  // This method is useful for implementing hard boundaries.
  // But it may cause problems, and may violate the presumption of `tryStepbackFrom`.
  public boolean tryPushbackFrom(Item target, int direction) {
    float backMovement = getPenetrationDepthOf(target, direction);
    if (backMovement < 0) { return false; }
    backMovement += epsilon;
    doMovementTo(-backMovement, direction);
    onStepback(target);
    return true;
  }

  public void onStepback(Item target) {}

  private float getPenetrationDepthOf(Item target) {
    return getPenetrationDepthOf(target, getDirection());
  }
  private float getPenetrationDepthOf(Item target, int direction) {
    switch (direction) {
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
    doMovementTo(distance, getDirection());
  }
  private void doMovementTo(float distance, int direction) {
    switch (direction) {
      case UPWARD: { moveY(-distance); break; }
      case RIGHTWARD: { moveX(distance); break; }
      case DOWNWARD: { moveY(distance); break; }
      case LEFTWARD: { moveX(-distance); break; }
    }
  }
}
