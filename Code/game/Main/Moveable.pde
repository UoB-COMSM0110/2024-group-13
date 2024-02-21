public class Moveable extends Object {
  int facing;
  
  public Moveable(String filename, int x, int y, int facing) {
    super(filename, x, y);
    this.facing = facing;
  }
  
  public Moveable(String filename, int x, int y) {
    super(filename, x, y);
    this.facing = UP_FACING;
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
