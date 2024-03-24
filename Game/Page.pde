import java.util.Collections;

// Page is somewhat to the player the window of the game.
// Page holds all the items in the window,
// and is responsible for updating and drawing them.
public class Page {
  private HashMap<String, SynchronizedItem> syncItems;
  private HashMap<String, LocalItem> localItems;
  private Page previousPage; // With this attribute, we can form a page stack.
  private Page nextPage;

  public Page(Page previousPage) {
    this.syncItems = new HashMap<String, SynchronizedItem>();
    this.localItems = new HashMap<String, LocalItem>();
    this.previousPage = previousPage;
    this.nextPage = null;
  }

  public void onSwitchOut() {}
  public void onSwitchIn() {}

  public void addLocalItem(LocalItem item) {
    localItems.put(item.getName(), item);
  }

  public void addSyncItem(SynchronizedItem item) {
    syncItems.put(item.getName(), item);
  }

  public boolean deleteItem(String name) {
    Item deleted = this.syncItems.remove(name);
    if (deleted  == null) {
      deleted = this.localItems.remove(name);
    }
    return deleted != null;
  }

  public ArrayList<SynchronizedItem> getSyncItems() {
    return new ArrayList<SynchronizedItem>(this.syncItems.values());
  }

  public ArrayList<LocalItem> getLocalItems() {
    return new ArrayList<LocalItem>(this.localItems.values());
  }

  // Update all the items, including sync ones and local ones.
  public void update() {
    ArrayList<Event> events = eventRecorder.fetchEvents();
    evolveSyncItems(events);
    dispatchEventsToLocalItems(events);
    updateItems();
  }

  void evolveSyncItems(ArrayList<Event> events) {
    // if (isClient) {
    //   sendEvents();
    //   receiveItems();
    // } else { // isServer
    //   receiveEvents();
    getSyncItems().forEach((item) -> { item.onEvents(events); });
    getSyncItems().forEach((item) -> { item.evolve(); });
    (new CollisionEngine()).solveCollisions();
    //   sendItems();
    // }
  }

  void dispatchEventsToLocalItems(ArrayList<Event> events) {
    getLocalItems().forEach((item) -> { item.onEvents(events); });
  }

  void updateItems() {
    getSyncItems().forEach((item) -> { item.update(); });
    getLocalItems().forEach((item) -> { item.update(); });
  }

  // Draw all the items, including sync ones and local ones.
  public void draw() {
    ArrayList<Item> items = new ArrayList<Item>();
    items.addAll(getSyncItems());
    items.addAll(getLocalItems());
    Collections.sort(items, new ItemLayerComparator());
    for (Item item : items) {
      if (!item.isDiscarded()) { item.draw(); }
    }
  }

  public Page getPreviousPage() { return this.previousPage; }

  public void trySwitchPage(Page nextPage) {
    if (this.nextPage == null) { this.nextPage = nextPage; }
  }

  // Whether the page should be replaced with next one.
  public boolean isObsolete() { return this.nextPage != null; }

  // Generate the next page.
  public Page fetchNextPage() {
    if (!isObsolete()) { return this; }
    Page next = this.nextPage;
    this.nextPage = null;
    return next;
  }
}
