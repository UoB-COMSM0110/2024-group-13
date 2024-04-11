import java.util.Collections;
import java.util.List;

// Page is somewhat to the player the window of the game.
// Page holds all the items in the window,
// and is responsible for updating and drawing them.
public abstract class Page {
  private String name;
  private HashMap<String, SynchronizedItem> syncItems;
  private HashMap<String, LocalItem> localItems;
  private ArrayList<Timer> localTimers;
  private ArrayList<Timer> timers;
  private Page previousPage; // With this attribute, we can form a page stack.
  private Page nextPage;

  public Page(String name, Page previousPage) {
    this.name = name;
    this.syncItems = new HashMap<String, SynchronizedItem>();
    this.localItems = new HashMap<String, LocalItem>();
    this.localTimers = new ArrayList<Timer>();
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

  public boolean deleteLocalItem(String name) {
    return this.localItems.remove(name) != null;
  }
  public boolean deleteSyncItem(String name) {
    return this.syncItems.remove(name) != null;
  }

  public void addLocalTimer(Timer timer) { this.localTimers.add(timer); }
  public void addTimer(Timer timer) { this.timers.add(timer); }

  // Update all the items, including sync ones and local ones.
  public void update() {
    ArrayList<Event> events = eventRecorder.fetchEvents();
    ArrayList<KeyboardEvent> keyboardEvents = new ArrayList<KeyboardEvent>();
    for (Event e : events) {
      if (e instanceof KeyboardEvent) { keyboardEvents.add((KeyboardEvent)e); }
    }
    runLocalTimers();
    dispatchEventsToLocalItems(events);
    evolveSyncItems(keyboardEvents);
    updateItems();
  }

  public void runLocalTimers() {
    List<Timer> timerList = this.localTimers;
    this.localTimers = new ArrayList<Timer>();
    this.localTimers.addAll(runTimerList(timerList));
  }
  public void runTimers() {
    List<Timer> timerList = this.timers;
    this.timers = new ArrayList<Timer>();
    this.timers.addAll(runTimerList(timerList));
  }

  private ArrayList<Timer> runTimerList(List<Timer> timerList) {
    ArrayList<Timer> continuedTimers = new ArrayList<Timer>();
    for (Timer timer : timerList) {
      if (timer.due()) {
        timer.run();
      }
      if (!timer.expired()) {
        continuedTimers.add(timer);
      }
    }
    return continuedTimers;
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
    if (clientMessages == null) { return; } // Exception
    for (String str : clientMessages) {
      str = str.trim();
      if (str.length() <= 0) { continue; }
      JSONObject msgJsonFromClient = parseJSONObject(str);
      JSONObject infoJson = msgJsonFromClient.getJSONObject("info");
      if (!dispatchSyncInfo(infoJson)) { return; }
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
    Integer writeBytes = gameInfo.writeSocketServer(msgToClient);
    if (writeBytes == null) { return; } // Exception
    if (isSwitching()) { gameInfo.writeOutSocketServer(2000); }
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
    Integer writeBytes = gameInfo.writeSocketClient(msgToServer);
    if (writeBytes == null) { return; } // Exception

    ArrayList<String> serverMessages = null;
    serverMessages = gameInfo.readSocketClient();
    if (serverMessages == null) { return; } // Exception
    for (String str : serverMessages) {
      str = str.trim();
      if (str.length() <= 0) { continue; }
      JSONObject msgJsonFromServer = parseJSONObject(str);
      JSONObject infoJson = msgJsonFromServer.getJSONObject("info");
      if (!dispatchSyncInfo(infoJson)) { return; }
      if (!getName().equals(infoJson.getString("page"))) { continue; } // This causes problems!
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

  // This method is in fact only used by `PlayPage`.
  public void doEvolve(ArrayList<KeyboardEvent> events) {
    runTimers();
    ArrayList<SynchronizedItem> items = getSyncItems();
    for (KeyboardEvent e : events) {
      for (SynchronizedItem item : items) {
        item.onKeyboardEvent(e);
      }
    }
    items.forEach((item) -> { item.evolve(); });
    // Currently the game only ends during collision solving.
    // So `PlayPage` passes a stop condition to the collision engine.
    // If the game can end during other stages, e.g., during timer running,
    // then the whole `doEvolve` method may need a stop condition.
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
    json.setBoolean("leaving", isLeavingGame());
    return json;
  }
  public boolean isLeavingGame() { return false; }

  public boolean dispatchSyncInfo(JSONObject json) {
    if (json.getBoolean("leaving")) {
      onCounterpartLeave();
      return false;
    }
    return true;
  }

  public void updateItems() {
    getSyncItems().forEach((item) -> { item.update(); });
    getLocalItems().forEach((item) -> { item.update(); });
  }

  public Page getPreviousPage() { return this.previousPage; }

  public void trySwitchPage(Page nextPage) {
    if (this.nextPage == null) { switchPage(nextPage); }
  }
  public void switchPage(Page nextPage) { this.nextPage = nextPage; }
  public void stopSwitchingPage() { this.nextPage = null; }

  // Whether the page should be replaced with next one.
  public boolean isObsolete() { return isSwitching(); }
  public boolean isSwitching() { return this.nextPage != null; }
  public boolean isSwitchingTo(String pageName) {
    return isSwitching() && this.nextPage.getName().equals(pageName);
  }

  // Generate the next page.
  public Page fetchNextPage() {
    if (!isSwitching()) { return this; }
    Page next = this.nextPage;
    this.nextPage = null;
    return next;
  }

  public void onConnectionStart() {}
  public void onNetworkFailure(String message) {
    System.err.println(message);
    gameInfo.stopSync();
  }
  public void onCounterpartLeave() { gameInfo.stopSync(); }
  public void onConnectionClose() {}
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

  public float[] getLocalCoord(float x, float y, float w, float h) {
    float[] coord = new float[4];
    coord[0] = gameInfo.getMapOffsetX() + x * gameInfo.getMapScaleX();
    coord[1] = gameInfo.getMapOffsetY() + y * gameInfo.getMapScaleY();
    coord[2] = w * gameInfo.getMapScaleX();
    coord[3] = h * gameInfo.getMapScaleY();
    return coord;
  }
}


public SynchronizedItem createSyncItemFromJson(JSONObject json) {
  SynchronizedItem item = null;
  String type = json.getString("class");
  if (type.equals("Border")) {
    item = new Border("", 0, 0, -1);
  } else if (type.equals("BreakableWall")) {
    item = new BreakableWall();
  } else if (type.equals("IndestructableWall")) {
    item = new IndestructableWall();
  } else if (type.equals("Coin")) {
    item = new Coin();
  } else if (type.equals("Bullet")) {
    item = new Bullet(-1);
  } else if (type.equals("PacmanShelter")) {
    item = new PacmanShelter(-1);
  } else if (type.equals("Ghost")) {
    item = new Ghost();
  } else if (type.equals("Pacman")) {
    item = new Pacman(-1);
  } else if (type.equals("OpponentControlPowerUp")) {
    item = new OpponentControlPowerUp();
  } else if (type.equals("TeleportPowerUp")) {
    item = new TeleportPowerUp();
  } else if (type.equals("TimeFreezePowerUp")) {
    item = new TimeFreezePowerUp();
  } else if (type.equals("SizeModificationPowerUp_Pacman")) {
    item = new SizeModificationPowerUp_Pacman();
  } else if (type.equals("SizeModificationPowerUp_Ghost")) {
    item = new SizeModificationPowerUp_Ghost();
  } else if (type.equals("TrapPowerUp")) {
    item = new TrapPowerUp();
  } else if (type.equals("Trap")) {
    item = new Trap(-1);
  } else if (type.equals("GhostMagnetPowerUp")) {
    item = new GhostMagnetPowerUp();
  } else if (type.equals("Magnet")) {
    item = new Magnet();
  } else if (type.equals("SpeedSurgePowerUp")) {
    item = new SpeedSurgePowerUp();
  } else {
    System.err.println("unknown item type " + type);
    return null;
  }
  item.setStateJson(json);
  return item;
}
