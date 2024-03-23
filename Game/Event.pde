// Base class for all events.
// Event is mainly used for dealing with user inputs.
public class Event {
  public Event() {}
}


// Base class for all keyboard events.
public class KeyboardEvent extends Event {
  private char key; // The key with which the event is associated.
  private int keyCode;

  public KeyboardEvent(char key, int keyCode) {
    super();
    this.key = key;
    this.keyCode = keyCode;
  }

  public char getKey() { return key; }

  public int getKeyCode() { return keyCode; }
}


public class KeyPressedEvent extends KeyboardEvent {
  public KeyPressedEvent(char key, int keyCode) {
    super(key, keyCode);
  }
}


public class KeyReleasedEvent extends KeyboardEvent {
  public KeyReleasedEvent(char key, int keyCode) {
    super(key, keyCode);
  }
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
    this.events = new ArrayList<Event>();
  }
  
  public ArrayList<Event> fetchEvents() {
    ArrayList<Event> current_events = this.events;
    this.events = new ArrayList<Event>();
    return current_events;
  }

  public void dropEvents() { this.events = new ArrayList<Event>(); }

  public void recordKeyPressed() {
    events.add(new KeyPressedEvent(key, keyCode));
  }

  public void recordKeyReleased() {
    events.add(new KeyReleasedEvent(key, keyCode));
  }

  public void recordMouseClicked() {
    events.add(new MouseClickedEvent(mouseX, mouseY));
  }
}
