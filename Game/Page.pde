import java.util.Collections;

// Page is somewhat to the player the window of the game.
// Page holds all the items in the window,
// and is responsible for updating and drawing them.
public class Page {
  private HashMap<String, SynchronizedItem> syncItems;
  private HashMap<String, LocalItem> localItems;
  public Page previousPage; // With this attribute, we can form a page stack.

  public Page(GameInfo gInfo, Page previousPage) {
    syncItems = new HashMap<String, SynchronizedItem>();
    localItems = new HashMap<String, LocalItem>();
    this.previousPage = previousPage;
  }

  public void addLocalItem(LocalItem item) {
    localItems.put(item.getName(), item);
  }

  public void addSyncItem(SynchronizedItem item) {
    syncItems.put(item.getName(), item);
  }

  public ArrayList<SynchronizedItem> getSyncItems() {
    ArrayList<SynchronizedItem> items = new ArrayList<SynchronizedItem>();
    this.syncItems.forEach((name, e) -> {
        if (!e.isDiscarded()) { items.add(e); }
    });
    return items;
  }

  public ArrayList<LocalItem> getLocalItems() {
    ArrayList<LocalItem> items = new ArrayList<LocalItem>();
    this.localItems.forEach((name, e) -> {
        if (!e.isDiscarded()) { items.add(e); }
    });
    return items;
  }

  // Update all the items, including sync ones and local ones.
  public void update(GameInfo gInfo, ArrayList<Event> events) {
    evolveSyncItems(gInfo, events);
    dispatchEventsToLocalItems(gInfo, events);
    updateItems(gInfo);
  }

  void evolveSyncItems(GameInfo gInfo, ArrayList<Event> events) {
    // if (isClient) {
    //   sendEvents();
    //   receiveItems();
    // } else { // isServer
    //   receiveEvents();
    syncItems.forEach((name, item) -> { item.onEvents(gInfo, this, events); });
    syncItems.forEach((name, item) -> { item.evolve(gInfo, this); });
    CollisionEngine.solveCollisions(gInfo, this);
    //   sendItems();
    // }
  }

  void dispatchEventsToLocalItems(GameInfo gInfo, ArrayList<Event> events) {
    localItems.forEach((name, item) -> { item.onEvents(gInfo, this, events); });
  }

  void updateItems(GameInfo gInfo) {
    syncItems.forEach((name, item) -> { item.update(gInfo, this); });
    localItems.forEach((name, item) -> { item.update(gInfo, this); });
  }

  // Draw all the items, including sync ones and local ones.
  public void draw(GameInfo gInfo) {
    ArrayList<Item> items = new ArrayList<Item>();
    items.addAll(getSyncItems());
    items.addAll(getLocalItems());
    Collections.sort(items, new ItemLayerComparator());
    items.forEach((item) -> { item.draw(gInfo); });
  }

  // Whether the page should be replaced with next one.
  public boolean isObsolete() { return false; }

  // Generate the next page.
  public Page getNextPage(GameInfo gInfo) { return this; }
}
