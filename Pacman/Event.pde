public class Event {
  public Event() {}
}


public class KeyboardEvent extends Event {
  private char key;

  public KeyboardEvent(char key) {
    super();
    this.key = key;
  }

  public float getKey() { return key; }
}


public class MouseEvent extends Event {
  private float x;
  private float y;

  public MouseEvent(float x, float y) {
    super();
    this.x = x;
    this.y = y;
  }

  public float getX() { return x; }
  public float getY() { return y; }
}


public class MouseClickedEvent extends MouseEvent {
  public MouseClickedEvent(float x, float y) {
    super(x, y);
  }
}


public class EventRecorder {
  ArrayList<Event> events;

  public EventRecorder() {
    events = new ArrayList<Event>();
  }
  
  public ArrayList<Event> getEvents() { return events; }

  public void clearEvents() { events.clear(); }

  public void recordMouseClicked() {
    events.add(new MouseClickedEvent(mouseX, mouseY));
  }
}
