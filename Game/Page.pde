import java.util.Collections;
import java.util.List;

// Page is somewhat to the player the window of the game.
// Page holds all the items in the window,
// and is responsible for updating and drawing them.
public abstract class Page {
  private String name;
  private HashMap<String, SynchronizedItem> syncItems;
  private HashMap<String, LocalItem> localItems;
  private ArrayList<Timer> timers;
  private Page previousPage; // With this attribute, we can form a page stack.
  private Page nextPage;

  private JSONArray syncChangesRecord;

  public Page(String name, Page previousPage) {
    this.name = name;
    this.syncItems = new HashMap<String, SynchronizedItem>();
    this.localItems = new HashMap<String, LocalItem>();
    this.timers = new ArrayList<Timer>();
    this.previousPage = previousPage;
    this.nextPage = null;
    this.syncChangesRecord = new JSONArray();
  }

  public String getName() { return this.name; }

  public void onSwitchOut() {}
  public void onSwitchIn() {}

  public void addLocalItem(LocalItem item) { localItems.put(item.getName(), item); }

  public void addSyncItem(SynchronizedItem item) {
    syncItems.put(item.getName(), item);
  }

  public LocalItem getLocalItem(String name) { return this.localItems.get(name); }
 
  public SynchronizedItem getSyncItem(String name) {return this.syncItems.get(name);}

  public ArrayList<SynchronizedItem> getSyncItems() {
    return new ArrayList<SynchronizedItem>(this.syncItems.values());
  }

  public ArrayList<LocalItem> getLocalItems() {
    return new ArrayList<LocalItem>(this.localItems.values());
  }

  public boolean deleteSyncItem(String name) {
    if (this.syncItems.remove(name) == null) { return false; }
    if (!gameInfo.isSingleHost()) { // TODO
      JSONObject deleted = new JSONObject();
      deleted.setString("name", name);
      this.syncChangesRecord.append(deleted);
    }
    return true;
  }

  public boolean deleteLocalItem(String name) {
    return this.localItems.remove(name) != null;
  }

  public void addTimer(Timer timer) { this.timers.add(timer); }

  // Update all the items, including sync ones and local ones.
  public void update() {
    ArrayList<Event> events = eventRecorder.fetchEvents();
    ArrayList<KeyboardEvent> keyboardEvents = new ArrayList<KeyboardEvent>();
    for (Event e : events) {
      if (e instanceof KeyboardEvent) { keyboardEvents.add((KeyboardEvent)e); }
    }
    runTimers();
    dispatchEventsToLocalItems(events);
    evolveSyncItems(keyboardEvents);
    updateItems();
  }

  public void runTimers() {
    ArrayList<Timer> oldTimers = this.timers;
    this.timers = new ArrayList<Timer>();
    for (Timer timer : oldTimers) {
      if (timer.due()) {
        timer.run();
      }
      if (!timer.expired()) {
        addTimer(timer);
      }
    }
  }

  public void dispatchEventsToLocalItems(ArrayList<Event> events) {
    getLocalItems().forEach((item) -> { item.onEvents(events); });
  }

  public JSONObject getSyncInfo() {
    JSONObject json = new JSONObject();
    json.setString("page", getName());
    String nextPageName = "";
    if (this.nextPage != null) { nextPageName = this.nextPage.getName(); }
    json.setString("nextPage", nextPageName);
    json.setInt("lastEvolveTimeMs", gameInfo.getLastEvolveTimeMs());
    // json.setString("player1", gameInfo.getPlayerName1());
    // json.setString("player2", gameInfo.getPlayerName2());
    json.setBoolean("closing", false);
    return json;
  }

  public void dispatchSyncInfo(JSONObject json) {}

  public void evolveSyncItems(ArrayList<KeyboardEvent> events) {
    if (gameInfo.isSingleHost()) {
      doEvolve(events);
      return;
    }

    JSONObject msgJson = new JSONObject();
    msgJson.setJSONObject("info", getSyncInfo());
    events.forEach((e) -> { e.setHostId(serverHostId); }); // TODO
    msgJson.setJSONArray("events", keyboardEventsToJson(events));
    gameInfo.writeSocketClient(msgJson.toString());

    ArrayList<String> clientMessages = gameInfo.readSocketServer();
    for (String str : clientMessages) {
      if (str.length() <= 0) { continue; }
      JSONObject msgJson = parseJSONObject(str);
      JSONObject infoJson = msgJson.getJSONObject("info");
      dispatchSyncInfo(infoJson);
      if (!getName().equals(infoJson.getString("page"))) { continue; }
      JSONArray eventsJson = msgJson.getJSONArray("events");
      ArrayList<KeyboardEvent> clientEvents = keyboardEventsFromJson(eventsJson);
      clientEvents.forEach((e) -> { e.setHostId(clientHostId); }); // TODO
      events.addAll(clientEvents);
    }
    if (true) { // Game not over
      doEvolve(events);
    }
    if (gameInfo.isServerSendBufferEmpty()) {
      for (SynchronizedItem item : this.syncItems.values()) {
        JSONObject json = item.getStateJson();
        String str = json.toString();
        if (!str.equals(item.getStoredStateStr())) {
          item.storeStateStr(str);
          this.syncChangesRecord.append(json);
        }
      }
      JSONObject msgJson = new JSONObject();
      msgJson.setJSONObject("info", getSyncInfo());
      msgJson.setJSONArray("changes", this.syncChangesRecord);
      gameInfo.writeSocketServer(msgJson.toString());
      clearSyncChangeRecord();
    }

    ArrayList<String> serverMessages = gameInfo.readSocketClient();
    for (String str : serverMessages) {
      if (str.length() <= 0) { continue; }
      JSONObject msgJson = parseJSONObject(str);
      JSONObject infoJson = msgJson.getJSONObject("info");
      dispatchSyncInfo(infoJson);
      if (!getName().equals(infoJson.getString("page"))) { continue; }
      JSONArray changesJson = msgJson.getJSONArray("changes");
      applyChangesFromJson(changesJson);
    }
  }

  public void onConnectionClose() {}

  public void doEvolve(ArrayList<KeyboardEvent> events) {
    getSyncItems().forEach((item) -> { item.onKeyboardEvents(events); });
    getSyncItems().forEach((item) -> { item.evolve(); });
    (new CollisionEngine()).solveCollisions();
    gameInfo.updateEvolveTime();
  }

  public void applyChangesFromJson(JSONArray changesJson) {
    for (int i = 0; i < changesJson.size(); ++i) {
      JSONObject json = changesJson.getObject(i);
      String name = json.getString("name");
      String type = json.getString("class", "");
      if (type.length() <= 0) {
        deleteSyncItem(name);
        continue;
      }
      SynchronizedItem item = getSyncItem(name);
      if (item == null) {
        SynchronizedItem item = createSyncItemFromJson(json);
        addSyncItem(item);
      } else {
        item.setStateFromJson(json);
      }
    }
  }

  public void clearSyncChangeRecord() { this.syncChangesRecord = new JSONArray(); }

  public void updateItems() {
    getSyncItems().forEach((item) -> { item.update(); });
    getLocalItems().forEach((item) -> { item.update(); });
  }

  // Draw all the items, including sync ones and local ones.
  public void draw() {
    drawItems(getSyncItems());
    drawItems(getLocalItems());
  }

  private void drawItems(List<? extends Item> items) {
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
