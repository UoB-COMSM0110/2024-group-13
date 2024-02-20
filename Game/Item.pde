static final int UP_FACING = 0;
static final int RIGHT_FACING = 1;
static final int DOWN_FACING = 2;
static final int LEFT_FACING = 3;

public class Item {
  String name;
  float x, y; // Position of the item's top-left corner.
  float w, h;
  int facing;
  int layer; // [-2, 2]
  boolean discarded;

  public Item(String name, float x, float y, float w, float h) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  public void display() {
    display(0, 0);
  }
  
  public void display(float offset_x, float offset_y) {}
  
  public void discard() {
    this.discarded = true;
  }
  
  public float getTop() {
    return y;
  }
  
  public float getBottom() {
    return y + h;
  }
  
  public float getLeft() {
    return x;
  }
  
  public float getRight() {
    return x + w;
  }
}
