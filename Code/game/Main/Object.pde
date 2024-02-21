public class Object {
  PImage img;
  // (x,y) is the top-left corner of the image
  float x, y;
  float w, h;
  boolean isDelete;
  
  public Object(String filename, float x, float y) {
    img = loadImage(filename);
    w = img.width;
    h = img.height;
    this.x = x;
    this.y = y;
    this.isDelete = false;
  }
  
  public Object(String filename) {
    img = loadImage(filename);
    this.x = 0;
    this.y = 0;
    this.isDelete = false;
  }
  
  public Object(PImage img) {
    this.img = img;
    this.x = 0;
    this.y = 0;
    this.isDelete = false;
  }
  
  public void display() {
    image(img, x, y, w, h);
  }
  
  public void delete() {
    this.isDelete = true;
  }
  
  // get boundary
  float getTopBoundary() {
    return y;
  }
  
  float getBottomBoundary() {
    return y + h;
  }
  
  float getLeftBoundary() {
    return x;
  }
  
  float getRightBoundary() {
    return x + w;
  }
  
  
}
