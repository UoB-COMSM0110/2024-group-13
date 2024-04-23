GameInfo gameInfo;
EventRecorder eventRecorder;

Page page;

void setup(){
  size(800, 680); // Needs to be the first line of `setup`.

  // Create the top-level game objects.
  gameInfo = new GameInfo();
  windowResize((int)gameInfo.getWinWidth(), (int)gameInfo.getWinHeight());
  eventRecorder = new EventRecorder();

  frameRate(gameInfo.getFrameRateConfig());
  loadResouces();

  // Create the start page.
  page = new StartPage(null);
  page.onSwitchIn();
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
  page.draw();
}


// ********************************
// Resouces loading.
// ********************************

final int fontSizeDefault = 20;
final String fontPathMinecraft = "data/Minecraft.ttf";
PFont fontMinecraft;
final String fontPathErikaType = "data/ErikaType.ttf";
PFont fontErikaType;

final String imagePathStartPageBackground = "data/StartPageBackground.png";
PImage imageStartPageBackground;
final String imagePathHelpPageOverlay = "data/HelpPageOverlay.png";
PImage imageOverlay;
final String imagePathInstructionSet = "data/InstructionSet.png";
PImage imageInstruction;

final String imagePathButton = "data/Button.png";
PImage imageButton;
final String imagePathHeart = "data/Heart.png";
PImage imageHeart;


void loadResouces() {
  loadResourcesForItems();
  loadResourcesForFigures();
  loadResourcesForPowerUps();

  fontMinecraft = createFont(fontPathMinecraft, fontSizeDefault, true);
  fontErikaType = createFont(fontPathErikaType, fontSizeDefault, true);

  imageStartPageBackground = loadImage(imagePathStartPageBackground);
  imageOverlay = loadImage(imagePathHelpPageOverlay);
  imageInstruction = loadImage(imagePathInstructionSet);

  imageButton = loadImage(imagePathButton);
  imageHeart = loadImage(imagePathHeart);
}


// ********************************
// User input evnets.
// ********************************

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
