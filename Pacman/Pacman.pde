//TESTTTTT CAN YOU SEE THIS

Game game;


void setup(){
  size(800, 600); // Use `windowResize` to resize window

  // Create the Game object.
  GameInfo gInfo = new GameInfo();
  frameRate(gInfo.getFrameRateConfig());

  StartPage startPage = new StartPage(gInfo, null);
  game = new Game(gInfo, startPage);
}

void draw() {
  game.updateInfo();
  game.updatePage();
  game.drawPage();
}


// Game holds the GameInfo, an EventRecorder and the current page.
// It updates and draws the page, and replace it with next page when necessary.
public class Game {
  private GameInfo gInfo;
  public Page page;
  private EventRecorder eventRecorder;

  public Game(GameInfo gInfo, Page startPage) {
    this.gInfo = gInfo;
    this.page = startPage;
    eventRecorder = new EventRecorder();
  }

  public EventRecorder getEventRecorder() { return eventRecorder; }
  
  // Update GameInfo.
  public void updateInfo() {
    gInfo.update();
    System.out.println("frame interval: " + gInfo.getLastFrameIntervalMs());
  }

  // Update the current page. Replace it when necessary.
  public void updatePage() {
    if (page.isObsolete()) {
      page = page.getNextPage(gInfo);
      eventRecorder.clearEvents();
    }
    page.update(gInfo, eventRecorder.getEvents());
    eventRecorder.clearEvents();
  }

  // Draw the current page.
  public void drawPage() {
    background(0);
    page.draw(gInfo);
  }
}


void keyPressed() {
  game.getEventRecorder().recordKeyPressed();
}

void keyReleased() {
  game.getEventRecorder().recordKeyReleased();
}

// void keyTyped() {
//   game.getEventRecorder().recordKeyTyped();
// }

// void mousePressed() {
//   game.getEventRecorder().recordMousePressed();
// }
// 
// void mouseReleased() {
//   game.getEventRecorder().recordMouseReleased();
// }

void mouseClicked() {
  game.getEventRecorder().recordMouseClicked();
}
