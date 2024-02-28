// Base class for all events.
// Event is mainly used for dealing with user inputs.
public class Event {
  public Event() {}
}


// Base class for all keyboard events.
public class KeyboardEvent extends Event {
  private char key; // The key with which the event is associated.

  public KeyboardEvent(char key) {
    super();
    this.key = key;
  }
  // corrected to return a char
  public char getKey() { return key; }
}


// Base class for all mouse events.
public class MouseEvent extends Event {
  private float x; // The mouse cursor position when the event occurs.
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


// EventRecorder is used to store all the events between two game frames.
// These events are processed when the frame refreshes.
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
