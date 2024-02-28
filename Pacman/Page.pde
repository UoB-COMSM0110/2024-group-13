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
    //   dispatchEventsToSyncItems();
    //   for (SynchronizedItem item : allSyncItems) {
    //     item.evolve(gInfo);
    //   }
    //   CollisionEngine.solveCollisions(gInfo, allSyncItems);
    //   sendItems();
    // }
    syncItems.forEach((name, item) -> { item.evolve(gInfo); });
  }

  void dispatchEventsToLocalItems(GameInfo gInfo, ArrayList<Event> events) {
    localItems.forEach((name, item) -> { item.onEvents(gInfo, events); });
  }

  void updateItems(GameInfo gInfo) {
    syncItems.forEach((name, item) -> { item.update(gInfo, this); });
    localItems.forEach((name, item) -> { item.update(gInfo, this); });
  }

  // Draw all the items, including sync ones and local ones.
  public void draw(GameInfo gInfo) {
    ArrayList<Item> items = new ArrayList<Item>();
    syncItems.forEach((name, item) -> { items.add(item); });
    localItems.forEach((name, item) -> { items.add(item); });
    Collections.sort(items, new ItemLayerComparator());
    items.forEach((item) -> { item.draw(gInfo); });
  }

  // Whether the page should be replaced with next one.
  public boolean isObsolete() { return false; }

  // Generate the next page.
  public Page getNextPage(GameInfo gInfo) { return this; }
}
