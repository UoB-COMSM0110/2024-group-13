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

  public void onEvents(GameInfo gInfo, ArrayList<Event> events) {}

  public void update(GameInfo gInfo, Page page) {}

  public PImage getImage() { return null; }

  public void draw(float offset_x, float offset_y) {
    PImage img = getImage();
    if (img == null) { return; }
    image(img, offset_x + x, offset_y + y, w, h);
  }
}


public class LocalItem extends Item {
  public LocalItem(String name, float x, float y) {
    super(name, x, y);
  }
  
  public void draw() {
    draw(0.0, 0.0);
  }
}


public class SynchronizedItem extends Item {
  public SynchronizedItem(String name, float x, float y) {
    super(name, x, y);
  }

  public void evolve(GameInfo gInfo) {}

  public void onCollisionWith(GameInfo gInfo, SynchronizedItem item) {}

  public String serialize() { return ""; }
}


public class MovableItem extends SynchronizedItem {
  private float speed;
  private int direction;
  private boolean moving;
  
  public Item(String name, float x, float y, float w, float h) {
    super(name, x, y, w, h);
  }
  
  public void startMoving() { moving = true; }
  public void stopMoving() { moving = false; }
}
