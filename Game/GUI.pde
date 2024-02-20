class Button {
  float x, y; // 按钮的位置
  float width, height; // 按钮的尺寸
  String label; // 按钮上的文字
  int baseColor, highlightColor, strokeColor; // 基本颜色和高亮颜色
  boolean over = false; // 鼠标是否悬停在按钮上
  int textSize;
  float borderRadius;
  
  Button(float x, float y, float width, float height, String label, int textSize) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.label = label;
    this.baseColor = color(255, 204, 0);
    this.highlightColor = color(255, 255, 0);
    this.strokeColor = color(0, 0, 255);
    this.borderRadius = 15;
    this.textSize = textSize;
  }

  void update() {
    // 检查鼠标是否悬停在按钮上
    if (mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height) {
      over = true;
    } else {
      over = false;
    }
  }

  void display() {
    // 根据鼠标是否悬停来改变颜色
    fill(over ? highlightColor : baseColor);
    rect(x, y, width, height, 20);
    fill(255);
    textSize(textSize);
    text(label, x + width / 2, y + height / 2);
  }

  boolean isClicked(float mx, float my) {
    return over; // 如果鼠标悬停在按钮上，则视为可点击
  }
}

class Screen {
  ArrayList<Button> buttons;

  Screen() {
    buttons = new ArrayList<Button>();
  }

  void addButton(Button button) {
    buttons.add(button);
  }

  void display() {
    for (Button button : buttons) {
      button.update(); // 更新按钮状态
      button.display(); // 显示按钮
    }
  }

  void handleClick(float mx, float my) {
    for (Button button : buttons) {
      if (button.isClicked(mx, my)) {
        println("Button clicked: " + button.label);
      }
    }
  }
}

class Game {
  Screen currentScreen;

  Game() {
    currentScreen = new Screen();
    // 添加按钮到屏幕
    currentScreen.addButton(new Button(width/2 - 100, 150, 200, 50, "START GAME", 20));
    currentScreen.addButton(new Button(width/2 - 100, 230, 200, 50, "CREATE ROOM", 20));
    currentScreen.addButton(new Button(width/2 - 100, 310, 200, 50, "HELP", 20));
    currentScreen.addButton(new Button(width/2 - 100, 390, 200, 50, "SET", 20));
  }

  void display() {
    currentScreen.display();
  }

  void handleClick(float mx, float my) {
    currentScreen.handleClick(mx, my);
  }
}

Game game;
String title = "Multiplayer Pac-man";
PFont titleFont; 
int titleFontSize = 60;

void setup() {
  size(800, 600);
  titleFont = createFont("Arial-Bold", titleFontSize); // 
  textFont(titleFont); //
  textAlign(CENTER, CENTER);
  game = new Game();
}

void draw() {
  background(0);
  // 显示游戏标题
  textFont(titleFont);
  //fill(255, 204, 0); 
  text(title, width / 2, height / 6); 

  // 显示按钮
  game.display();
}

void mousePressed() {
  game.handleClick(mouseX, mouseY);
}
