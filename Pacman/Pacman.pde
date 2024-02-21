Game game;


void setup(){
  size(800, 600); // Use `windowResize` to resize window
  frameRate(60);

  GameInfo gInfo = new GameInfo();
  StartPage startPage = new StartPage(gInfo, null);
  game = new Game(gInfo, startPage);
}


void draw() {
  game.updatePage();
  game.drawPage();
}


public class Game {
  private GameInfo gInfo;
  private Page page;
  private EventRecorder eventRecorder;

  public Game(GameInfo gInfo, Page startPage) {
    this.gInfo = gInfo;
    this.page = startPage;
    eventRecorder = new EventRecorder();
  }

  public EventRecorder getEventRecorder() { return eventRecorder; }

  public void updatePage() {
    if (page.isObsolete()) {
      page = page.getNextPage(gInfo);
      eventRecorder.clearEvents();
    }
    page.update(gInfo, eventRecorder.getEvents());
    eventRecorder.clearEvents();
  }

  public void drawPage() {
    page.draw(gInfo);
  }
}


// void keyPressed() {
//   game.getEventRecorder().recordKeyPressed();
// }
// 
// void keyReleased() {
//   game.getEventRecorder().recordKeyReleased();
// }
// 
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
