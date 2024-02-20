public class MovableItem extends Item {
  float speed;
  float direction;
  private boolean isMoving;
  
  public Item(String name, float x, float y, float w, float h) {
    super(name, x, y, w, h);
  }
  
  public void startMoving() { isMoving = true; }
  public void stopMoving() { isMoving = false; }

  public void progress(Game g) {
    if (isMoving) {}
  }
}
