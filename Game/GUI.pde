public class Button extends LocalItem {
  String text;
  int baseColor, highlightColor, strokeColor; // 基本颜色和高亮颜色
  boolean over = false; // 鼠标是否悬停在按钮上
  int textSize;
  float borderRadius;
  
  public Button(String name, float x, float y, String text) {
    super(name, x, y);
    this.text = text;

    this.baseColor = color(255, 204, 0);
    this.highlightColor = color(255, 255, 0);
    this.strokeColor = color(0, 0, 255);
    this.borderRadius = 15;
    this.textSize = textSize;
  }

  @Override
  void onEvents(GameInfo gInfo, ArrayList<Event> events) {
    for (Event e : events) {
    }
    // 检查鼠标是否悬停在按钮上
    if (mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height) {
      over = true;
    } else {
      over = false;
    }
  }
}
