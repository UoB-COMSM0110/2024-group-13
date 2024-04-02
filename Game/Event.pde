import java.util.List;

// Base class for all events.
// Event is mainly used for dealing with user inputs.
public class Event {
  private int hostId;

  public Event() {
    this.hostId = gameInfo.getHostId();
  }

  protected JSONObject getJson() {
    JSONObject json = new JSONObject();
    json.setString("class", getClass().getSimpleName());
    json.setInt("hostId", getHostId());
    return json;
  }
  protected void fromJson(JSONObject json) {
    this.hostId = json.getInt("hostId");
  }

  public int getHostId() { return this.hostId; }

  protected void setHostId(int hostId) { this.hostId = hostId; }
}


// Base class for all keyboard events.
public class KeyboardEvent extends Event {
  private int key; // The key with which the event is associated.
  private int keyCode;

  public KeyboardEvent(int key, int keyCode) {
    super();
    this.key = key;
    this.keyCode = keyCode;
  }

  @Override
  public JSONObject getJson() {
    JSONObject json = super.getStateJson();
    json.setInt("key", getKey());
    json.setInt("keyCode", getKeyCode());
    return json;
  }
  @Override
  public void fromJson(JSONObject json) {
    super.fromJson(json);
    this.key = json.getInt("key");
    this.keyCode = json.getInt("keyCode");
  }

  public int getKey() { return key; }

  public int getKeyCode() { return keyCode; }
}


public class KeyPressedEvent extends KeyboardEvent {
  public KeyPressedEvent(int key, int keyCode) {
    super(key, keyCode);
  }
}


public class KeyReleasedEvent extends KeyboardEvent {
  public KeyReleasedEvent(int key, int keyCode) {
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

  @Override
  public final JSONObject getJson() { return null; }
  @Override
  protected final void fromJson(JSONObject json) { return; }

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


// ----------------------------------------------------------------


static JSONArray keyboardEventsToJson(List<? extends KeyboardEvent> events) {
  JSONArray eventsJson = new JSONArray();
  for (KeyboardEvent e : events) { eventsJson.append(e.getJson()); }
  return eventsJson;
}


static ArrayList<KeyboardEvent> keyboardEventsFromJson(JSONArray eventsJson) {
  ArrayList<KeyboardEvent> events = new ArrayList<KeyboardEvent>();
  for (int i = 0; i < eventsJson.size(); ++i) {
    JSONObject json = eventsJson.getObject(i);
    KeyboardEvent e = null;
    String type = json.getString("class");
    if (type.equals("KeyPressedEvent")) {
      e = new KeyPressedEvent(0, 0);
    } else if (type.equals("KeyReleasedEvent")) {
      e = new KeyReleasedEvent(0, 0);
    } else {
      System.err.println("unknown event type " + type);
      continue;
    }
    e.fromJson(json);
    events.add(e);
  }
  return events;
}
