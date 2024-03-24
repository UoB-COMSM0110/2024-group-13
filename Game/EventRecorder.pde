// EventRecorder is used to store all the events between two game frames.
// These events are processed when the frame refreshes.
public class EventRecorder {
  private ArrayList<Event> events;

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
    events.add(new MouseClickedEvent(mouseX, mouseY, mouseButton));
  }

  public void recordMouseMoved() {
    events.add(new MouseMovedEvent(mouseX, mouseY));
  }
}
