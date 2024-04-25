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
  page = new HomePage();
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

final String imagePathButton = "data/Button.png";
PImage imageButton;
final String imagePathHeart3 = "data/Heart3.png";
PImage imageHeart3;
final String imagePathHeart2 = "data/Heart2.png";
PImage imageHeart2;
final String imagePathHeart1 = "data/Heart1.png";
PImage imageHeart1;
final String imagePathHeart0 = "data/Heart0.png";
PImage imageHeart0;
final String imagePathBulletPrompt = "data/BulletPrompt.png";
PImage imageBulletPrompt;
final String imagePathKeyset1 = "data/Keyset1.png";
PImage imageKeyset1;
final String imagePathKeyset2 = "data/Keyset2.png";
PImage imageKeyset2;

void loadResouces() {
  loadResourcesForItems();
  loadResourcesForFigures();
  loadResourcesForPowerUps();

  fontMinecraft = createFont(fontPathMinecraft, fontSizeDefault, true);
  fontErikaType = createFont(fontPathErikaType, fontSizeDefault, true);

  imageStartPageBackground = loadImage(imagePathStartPageBackground);
  imageOverlay = loadImage(imagePathHelpPageOverlay);

  imageButton = loadImage(imagePathButton);
  imageHeart3 = loadImage(imagePathHeart3);
  imageHeart2 = loadImage(imagePathHeart2);
  imageHeart1 = loadImage(imagePathHeart1);
  imageHeart0 = loadImage(imagePathHeart0);
  imageBulletPrompt = loadImage(imagePathBulletPrompt );
  imageKeyset1 = loadImage(imagePathKeyset1);
  imageKeyset2 = loadImage(imagePathKeyset2);
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
