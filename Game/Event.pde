// Base class for all events.
// Event is mainly used for dealing with user inputs.
public class Event {
  private int hostId;

  public Event() {
    this.hostId = gameInfo.getHostId();
  }
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
  int button;

  public MouseClickedEvent(float x, float y, int button) {
    super(x, y);
    this.button = button;
  }

  public int getButton() { return this.button; }
}


public class MouseMovedEvent extends MouseEvent {
  public MouseMovedEvent(float x, float y) {
    super(x, y);
  }
}
