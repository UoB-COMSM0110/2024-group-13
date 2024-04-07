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

  public Page(String name, Page previousPage) {
    this.name = name;
    this.syncItems = new HashMap<String, SynchronizedItem>();
    this.localItems = new HashMap<String, LocalItem>();
    this.timers = new ArrayList<Timer>();
    this.previousPage = previousPage;
    this.nextPage = null;
  }

  public String getName() { return this.name; }

  public void addLocalItem(LocalItem item) { this.localItems.put(item.getName(), item); }
  public void addSyncItem(SynchronizedItem item) { this.syncItems.put(item.getName(), item); }

  public LocalItem getLocalItem(String name) { return this.localItems.get(name); }
  public SynchronizedItem getSyncItem(String name) { return this.syncItems.get(name); }

  public ArrayList<LocalItem> getLocalItems() {
    return new ArrayList<LocalItem>(this.localItems.values());
  }
  public ArrayList<SynchronizedItem> getSyncItems() {
    return new ArrayList<SynchronizedItem>(this.syncItems.values());
  }

  public ArrayList<SynchronizedItem> getSyncItemsByNameAndCount(String name, int itemCount) {
     ArrayList<SynchronizedItem> res = new ArrayList<>();
     for (int i = 0; i < itemCount; i++) {
       res.add(syncItems.get(name + i));
     }
     return res;
  }

  public boolean deleteLocalItem(String name) {
    return this.localItems.remove(name) != null;
  }
  public boolean deleteSyncItem(String name) {
    return this.syncItems.remove(name) != null;
  }

  public void addTimer(Timer timer) { this.timers.add(timer); }

  // Update all the items, including sync ones and local ones.
  public void update() {
    ArrayList<Event> events = eventRecorder.fetchEvents();
    ArrayList<KeyboardEvent> keyboardEvents = new ArrayList<KeyboardEvent>();
    for (Event e : events) {
      if (e instanceof KeyboardEvent) { keyboardEvents.add((KeyboardEvent)e); }
    }
    runTimers(); // Run timers for both local and sync items.
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
    for (Event e : events) {
      for (LocalItem item : getLocalItems()) {
        item.onEvent(e);
      }
    }
  }

  public void evolveSyncItems(ArrayList<KeyboardEvent> events) {
    if (gameInfo.isServerHost()) {
      evolveSyncItemsServerSide(events);
    } else if (gameInfo.isClientHost()) {
      evolveSyncItemsClientSide(events);
    } else {
      doEvolve(events);
    }
  }

  public void evolveSyncItemsServerSide(ArrayList<KeyboardEvent> events) {
    ArrayList<String> clientMessages = null;
    clientMessages = gameInfo.readSocketServer();
    for (String str : clientMessages) {
      str = str.trim();
      if (str.length() <= 0) { continue; }
      JSONObject msgJsonFromClient = parseJSONObject(str);
      JSONObject infoJson = msgJsonFromClient.getJSONObject("info");
      dispatchSyncInfo(infoJson);
      if (!getName().equals(infoJson.getString("page"))) { continue; }
      JSONArray eventsJson = msgJsonFromClient.getJSONArray("events");
      if (eventsJson == null) { continue; }
      ArrayList<KeyboardEvent> clientEvents = keyboardEventsFromJson(eventsJson);
      events.addAll(clientEvents);
    }

    doEvolve(events);

    String msgToClient = null;
    JSONObject msgJsonToClient = getMsgJsonToClient();
    if (msgJsonToClient != null) { msgToClient = msgJsonToClient.toString(); }
    gameInfo.writeSocketClient(msgToClient);
  }

  public JSONObject getMsgJsonToClient() {
    JSONObject msgJsonToClient = new JSONObject();
    msgJsonToClient.setJSONObject("info", getSyncInfo());
    msgJsonToClient.setJSONArray("changes", getChangesJsonArray());
    return msgJsonToClient;
  }

  public JSONArray getChangesJsonArray() {
    return new JSONArray();
  }

  public void evolveSyncItemsClientSide(ArrayList<KeyboardEvent> events) {
    String msgToServer = null;
    JSONObject msgJsonToServer = getMsgJsonToServer(events);
    if (msgJsonToServer != null) { msgToServer = msgJsonToServer.toString(); }
    gameInfo.writeSocketClient(msgToServer);

    ArrayList<String> serverMessages = null;
    serverMessages = gameInfo.readSocketClient();
    for (String str : serverMessages) {
      str = str.trim();
      if (str.length() <= 0) { continue; }
      JSONObject msgJsonFromServer = parseJSONObject(str);
      JSONObject infoJson = msgJsonFromServer.getJSONObject("info");
      dispatchSyncInfo(infoJson);
      if (!getName().equals(infoJson.getString("page"))) { continue; }
      JSONArray changesJson = msgJsonFromServer.getJSONArray("changes");
      if (changesJson == null) { continue; }
      applyChangesFromJson(changesJson);
    }
  }

  public JSONObject getMsgJsonToServer(ArrayList<KeyboardEvent> events) {
    JSONObject msgJsonToServer = new JSONObject();
    msgJsonToServer.setJSONObject("info", getSyncInfo());
    msgJsonToServer.setJSONArray("events", getEventsJsonArray(events));
    return msgJsonToServer;
  }

  public JSONArray getEventsJsonArray(List<KeyboardEvent> events) {
    return new JSONArray();
  }

  public void applyChangesFromJson(JSONArray changesJson) {
    for (int i = 0; i < changesJson.size(); ++i) {
      JSONObject json = changesJson.getJSONObject(i);
      String name = json.getString("name");
      String type = json.getString("class");
      if (type == null || type.length() <= 0) {
        deleteSyncItem(name);
        continue;
      }
      SynchronizedItem item = getSyncItem(name);
      if (item != null) {
        item.setStateJson(json);
        continue;
      }
      item = createSyncItemFromJson(json);
      if (item != null) {
        addSyncItem(item);
      }
    }
  }

  public void doEvolve(ArrayList<KeyboardEvent> events) {
    ArrayList<SynchronizedItem> items = getSyncItems();
    for (KeyboardEvent e : events) {
      for (SynchronizedItem item : items) {
        item.onKeyboardEvent(e);
      }
    }
    items.forEach((item) -> { item.evolve(); });
    solveCollisions();
    gameInfo.updateEvolveTime();
  }

  public void solveCollisions() {}

  public JSONObject getSyncInfo() {
    JSONObject json = new JSONObject();
    json.setString("page", getName());
    String nextPageName = "";
    if (this.nextPage != null) { nextPageName = this.nextPage.getName(); }
    json.setString("nextPage", nextPageName);
    json.setString("player1", gameInfo.getPlayerName1());
    json.setString("player2", gameInfo.getPlayerName2());
    json.setBoolean("closing", false);
    return json;
  }

  public void dispatchSyncInfo(JSONObject json) {
    if (gameInfo.isServerHost()) {
      gameInfo.setPlayerName2(json.getString("player2"));
    }
    if (gameInfo.isClientHost()) {
      gameInfo.setPlayerName1(json.getString("player1"));
    }
  }

  public void onSyncStart() {}
  public void onConnectionStart() {}
  public void onNetworkFailure(String where, Exception e) {}
  public void onConnectionClose() {}

  public void updateItems() {
    getSyncItems().forEach((item) -> { item.update(); });
    getLocalItems().forEach((item) -> { item.update(); });
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

  public void onSwitchOut() {}
  public void onSwitchIn() {}

  // Draw all the items, including sync ones and local ones.
  public void draw() {
    drawBackground();
    drawSyncItems();
    drawLocalItems();
  }
  public void drawBackground() { background(255); }
  public void drawSyncItems() { drawItems(getSyncItems()); }
  public void drawLocalItems() { drawItems(getLocalItems()); }

  private void drawItems(List<? extends Item> items) {
    Collections.sort(items, new ItemLayerComparator());
    for (Item item : items) {
      if (!item.isDiscarded()) { item.draw(); }
    }
  }
}


public SynchronizedItem createSyncItemFromJson(JSONObject json) {
  SynchronizedItem item = null;
  String type = json.getString("class");
  if (type.equals("Border")) {
    item = new Border("", 0, 0);
  } else if (type.equals("BreakableWall")) {
    item = new BreakableWall(0, 0);
  } else if (type.equals("IndestructableWall")) {
    item = new IndestructableWall(0, 0);
  } else if (type.equals("Coin")) {
    item = new Coin(0, 0);
  } else if (type.equals("Bullet")) {
    item = new Bullet(0, 0);
  } else if (type.equals("Ghost")) {
    item = new Ghost(0, 0);
  } else if (type.equals("Pacman")) {
    item = new Pacman(0, 0, 0);
  } else if (type.equals("PowerUp")) {
    item = new PowerUp(0, 0);
  } else if (type.equals("OpponentControlPowerUp")) {
    item = new OpponentControlPowerUp(0, 0);
  } else {
    System.err.println("unknown item type " + type);
    return null;
  }
  item.setStateJson(json);
  return item;
}
