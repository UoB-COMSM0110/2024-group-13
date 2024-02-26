import java.util.Collections;

public class Page {
  private HashMap<String, SynchronizedItem> syncItems;
  private HashMap<String, LocalItem> localItems;
  private Page previousPage;

  public Page(GameInfo gInfo, Page previousPage) {
    syncItems = new HashMap<String, SynchronizedItem>();
    localItems = new HashMap<String, LocalItem>();
    this.previousPage = previousPage;
  }

  public void addLocalItem(LocalItem item) {
    localItems.put(item.getName(), item);
  }

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

  public void draw(GameInfo gInfo) {
    background(255);
    ArrayList<Item> items = new ArrayList<Item>();
    syncItems.forEach((name, item) -> { items.add(item); });
    localItems.forEach((name, item) -> { items.add(item); });
    Collections.sort(items, new ItemLayerComparator());
    items.forEach((item) -> { item.draw(gInfo); });
  }

  public boolean isObsolete() { return false; }

  public Page getNextPage(GameInfo gInfo) { return this; }
}
