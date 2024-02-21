Game game;

void setup(){
  game = new Game();
}

void draw() {
  game.updatePage();
  game.drawPage();
}

public class Game {
  private GameInfo gInfo;
  private Page page;
  private EventRecorder eventRecorder;

  public Game() {
    gInfo = new GameInfo();
    page = new StartPage(gInfo, null);
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
    page.draw();
  }
}

void keyPressed() {
  game.getEventRecorder().recordKeyPressed();
}

void keyReleased() {
  game.getEventRecorder().recordKeyReleased();
}

void keyTyped() {
  game.getEventRecorder().recordKeyTyped();
}

void mousePressed() {
  game.getEventRecorder().recordMousePressed();
}

void mouseReleased() {
  game.getEventRecorder().recordMouseReleased();
}

void mouseClicked() {
  game.getEventRecorder().recordMouseClicked();
}
