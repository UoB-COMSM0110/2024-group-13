GameInfo gameInfo;
EventRecorder eventRecorder;

Page page;

void setup(){
  size(800, 680); // Needs to be the first line of `setup`.

  // Create the top-level game objects.
  gameInfo = new GameInfo();
  eventRecorder = new EventRecorder();
  windowResize((int)gameInfo.getWinWidth(), (int)gameInfo.getWinHeight());

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
    page.onSwitchOut();
    eventRecorder.dropEvents();
    page = page.fetchNextPage();
    page.onSwitchIn();
  }

  // Update page and its items.
  page.update();

  // Draw page.
  background(0);
  page.draw();
}


// keyTyped()

void keyPressed() {
  eventRecorder.recordKeyPressed();
}

void keyReleased() {
  eventRecorder.recordKeyReleased();
}


// mousePressed()
// mouseReleased()
// mouseDragged()
// mouseWheel()

void mouseClicked() {
  eventRecorder.recordMouseClicked();
}

void mouseMoved() {
  eventRecorder.recordMouseMoved();
}
