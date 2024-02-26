import java.util.Comparator;

static final int UPWARD = 0;
static final int RIGHTWARD = 90;
static final int DOWNWARD = 180;
static final int LEFTWARD = 270;


public class Item {
  private String name;
  private float x, y; // Position of item top-left corner
  private float w, h;
  private boolean elliptic;
  private int facing;
  private int layer;
  private boolean discarded;

  public Item(String name, float x, float y) {
    this.name = name;
    this.x = x;
    this.y = y;
  }
  
  public Item setW(float w) { this.w = w; return this; }
  public Item setH(float h) { this.h = h; return this; }
  
  public float getX() { return x; }
  public float getY() { return y; }
  public float getW() { return w; }
  public float getH() { return h; }

  public String getName() { return name; }

  public int getLayer() { return layer; }

  public void onEvents(GameInfo gInfo, ArrayList<Event> events) {
    events.forEach((e) -> { onEvent(gInfo, e); });
  }

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

  public void update(GameInfo gInfo, Page page) {}

  public PImage getImage() { return null; }

  public void draw(GameInfo gInfo) {
    PImage img = getImage();
    if (img == null) { return; }
    image(img, x, y, w, h);
  }
}


public class ItemLayerComparator implements Comparator<Item> {
  public int compare(Item i1, Item i2) { return  i1.getLayer() - i2.getLayer(); }
}


public class LocalItem extends Item {
  public LocalItem(String name, float x, float y) {
    super(name, x, y);
  }
}


public class SynchronizedItem extends Item {
  public SynchronizedItem(String name, float x, float y) {
    super(name, x, y);
  }

  public void evolve(GameInfo gInfo) {}

  public void onCollisionWith(GameInfo gInfo, SynchronizedItem item) {}

  public String serialize() { return ""; }

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


public class MovableItem extends SynchronizedItem {
  private float speed;
  private int direction;
  private boolean moving;
  
  public MovableItem(String name, float x, float y) {
    super(name, x, y);
  }
  
  public void startMoving() { moving = true; }
  public void stopMoving() { moving = false; }
}
