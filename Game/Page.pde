import java.util.HashMap;

public class Page {
  private HashMap<String, SynchronizedItem> syncItems;
  private HashMap<String, LocalItem> localItems;
  private Page previousPage;

  public Page(GameInfo gInfo, Page previousPage) {
    syncItems = new HashMap<String, SynchronizedItem>();
    localItems = HashMap<String, LocalItem>();
    this.previousPage = previousPage;
  }

  public void update(GameInfo gInfo, ArrayList<Event> events) {
    evolveSyncItems(gInfo, events);
    dispatchEventsToLocalItems(gInfo, events);
    updateAllItems(gInfo);
  }

  void evolveSyncItems(gInfo, events) {
    if (isClient) {
      sendEvents(gInfo, events);
      receiveItems();
    } else { // isServer
      receiveEvents();
      dispatchEventsToSyncItems(gInfo, events);
      for (SynchronizedItem item : allSyncItems) {
        item.evolve(gInfo);
      }
      CollisionEngine.solveCollisions(gInfo, allSyncItems);
      sendItems();
    }
    synchronizeEvents(gInfo, events);
  }

  void updateAllItems(GameInfo gInfo) {
    for (Item item : allItems) {
      item.update(gInfo, this);
    }
  }

  public void draw() {
    // Sort all items by their layer,
    // then call draw() each item.
  }

  public boolean isObsolete() { return false; }

  public Page getNextPage(GameInfo gInfo) { return this; }
}
