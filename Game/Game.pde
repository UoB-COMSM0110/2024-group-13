GameInfo gameInfo;
EventRecorder eventRecorder;

Page page;

void setup(){
  // Create the top-level game objects.
  gameInfo = new GameInfo();
  eventRecorder = new EventRecorder();

  size(800, 600); // Use `windowResize` to resize window

  // Load resouces.
  loadResoucesForGameItems();
  loadResourcesForGui();
  loadResourcesForPlayPage();
  loadResoucesForFigures();

  // Create the start page.
  page = new StartPage(null);

  frameRate(gameInfo.getFrameRateConfig());
}

void draw() {
  // Update information, e.g., frame number, time, ...
  gameInfo.update();

  // Check whether to switch page.
  if (page.isObsolete()) {
    page = page.getNextPage();
    eventRecorder.dropEvents();
  }

  // Update page and its items.
  page.update();

  // Draw page.
  background(0);
  page.draw();
}


void keyPressed() {
  eventRecorder.recordKeyPressed();
}

void keyReleased() {
  eventRecorder.recordKeyReleased();
}

// void keyTyped() {
//   eventRecorder.recordKeyTyped();
// }

// void mousePressed() {
//   eventRecorder.recordMousePressed();
// }
// 
// void mouseReleased() {
//   eventRecorder.recordMouseReleased();
// }

int mouseClickCnt = 0;
void mouseClicked() {
  System.out.println("mouse clicked " + mouseClickCnt++);
  eventRecorder.recordMouseClicked();
}
