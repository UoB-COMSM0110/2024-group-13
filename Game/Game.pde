GameInfo gInfo;
EventRecorder eventRecorder;
Page page;

void setup(){
  size(800, 600); // Use `windowResize` to resize window

  // Load resouces.
  loadResoucesForGameItems();
  loadResourcesForGui();
  loadResourcesForGamePage();
  loadResoucesForFigures();

  // Create the top-level game object.
  gInfo = new GameInfo();
  eventRecorder = new EventRecorder();
  page = new StartPage(gInfo, null);

  frameRate(gInfo.getFrameRateConfig());
}

void draw() {
  // Update information, e.g., frame number, time, ...
  gInfo.update();
  System.out.println("frame interval: " + gInfo.getLastFrameIntervalMs());

  // Check whether to switch page.
  if (page.isObsolete()) {
    page = page.getNextPage(gInfo);
    eventRecorder.dropEvents();
  }
  // Update page and its items.
  page.update(gInfo, eventRecorder.fetchEvents());

  // Draw page.
  background(0);
  page.draw(gInfo);
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

void mouseClicked() {
  eventRecorder.recordMouseClicked();
}
