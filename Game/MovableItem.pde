public class MovableItem extends Item {
  float speed;
  float direction;
  boolean isMoving;
  
  public MovableItem(String name, int x, int y) {
    super(name, x, y);
  }
  
  public void move(float moveX, float moveY) {
    this.x += moveX;
    this.y += moveY;
    
    if (moveX > 0) {
      this.facing = RIGHT_FACING;
    } else if (moveX < 0) {
      this.facing = LEFT_FACING;
    } else if (moveY > 0) {
      this.facing = UP_FACING;
    } else if (moveY < 0){
      this.facing = DOWN_FACING;
    }  
  }
}
