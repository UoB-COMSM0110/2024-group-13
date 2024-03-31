import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;
import java.util.regex.Pattern;

// https://jenkov.com/tutorials/java-nio/selectors.html
// https://www.baeldung.com/java-nio-selector

// TODO: last evolve time instead of last frame time.
// TODO: reset username, user score, ..., after stop sync.
// TODO: page.onConnectionLost

static final int KB = 1024;
static final int MB = 1024 * KB;

static final int singleHostId = 0;
static final int serverHostId = 1;
static final int clientHostId = 2;

final int port = 2024;

final int bufferSize = 2 * MB;
final String messageDelim = "<MSGEOF>";


// A handy struct containing data cache for socket.
private class Cache {
  private boolean isSendingCache;
  public String data;
  public ByteBuffer buffer;

  public Cache(boolean isSendingCache) {
    this.isSendingCache = isSendingCache;
    this.buffer = ByteBuffer.allocate(bufferSize);
    reset();
  }

  public void reset() {
    this.data = "";
    this.buffer.clear();
    if (this.isSendingCache) { this.buffer.flip(); }
  }
}


// GameInfo holds some housekeeping information.
// For example, the size of the window, the ip/port of the other player, etc.
public class GameInfo {
  private int hostId;
  private boolean connected;

  private float windowWidth, windowHeight;
  private float mapWidth, mapHeight;
  // Coefficients used to transform sync-coordinates to local-coordinates.
  private float mapScaleX, mapScaleY;
  private float mapOffsetX, mapOffsetY;

  private int frameRateConfig;
  private long gameStartTimeMs;
  private long currentFrameTimeMs;
  private long lastFrameIntervalMs;

  private String playerName1;
  private String playerName2;

  private Selector selectorServer;
  private SocketChannel socketServer;
  private Cache sendCacheServer;
  private Cache recvCacheServer;

  private Selector selectorClient;
  private SocketChannel socketClient;
  private Cache sendCacheClient;
  private Cache recvCacheClient;

  public GameInfo() {
    this.hostId = singleHostId;
    this.connected = false;

    this.windowWidth = 800.0;
    this.windowHeight = 680.0;
    this.mapWidth = 800.0;
    this.mapHeight = 600.0;
    this.mapScaleX = 1.0;
    this.mapScaleY = 1.0;
    this.mapOffsetX = 0.0;
    this.mapOffsetY = 80.0;

    this.frameRateConfig = 50;
    this.gameStartTimeMs = System.currentTimeMillis();

    this.playerName1 = "Anonym1";
    this.playerName2 = "Anonym2";

    this.sendCacheServer = new Cache(true);
    this.recvCacheServer = new Cache(false);
    this.sendCacheClient = new Cache(true);
    this.recvCacheClient = new Cache(false);
  }

  public void setMapScaleX(float scale) { this.mapScaleX = scale; }
  public void setMapScaleY(float scale) { this.mapScaleY = scale; }
  public void setMapOffsetX(float offset) { this.mapOffsetX = offset; }
  public void setMapOffsetY(float offset) { this.mapOffsetY = offset; }

  public void setPlayerName1(String name) { this.playerName1 = name; }
  public void setPlayerName2(String name) { this.playerName2 = name; }

  public void update() {
    long lastFrameTimeMs = this.currentFrameTimeMs;
    this.currentFrameTimeMs = System.currentTimeMillis();
    if (frameCount > 1) {
      this.lastFrameIntervalMs = this.currentFrameTimeMs - lastFrameTimeMs;
    }
  }

  public int getHostId() { return this.hostId; }
  public boolean isConnected() { return this.connected; }

  public float getWinWidth() { return this.windowWidth; }
  public float getWinHeight() { return this.windowHeight; }
  public float getMapWidth() { return this.mapWidth; }
  public float getMapHeight() { return this.mapHeight; }

  public float getMapScaleX() { return this.mapScaleX; }
  public float getMapScaleY() { return this.mapScaleY; }
  public float getMapOffsetX() { return this.mapOffsetX; }
  public float getMapOffsetY() { return this.mapOffsetY; }

  public int getFrameRateConfig() { return this.frameRateConfig; }
  public long getFrameTimeMs() { return this.currentFrameTimeMs; }
  public long getLastFrameIntervalMs() { return this.lastFrameIntervalMs; }
  public float getLastFrameIntervalS() { return getLastFrameIntervalMs() / 1000.0; }

  public String getPlayerName1() { return this.playerName1; }
  public String getPlayerName2() { return this.playerName2; }

  public void startSyncAsServer() throws IOException {
    this.selectorServer = Selector.open();
    ServerSocketChannel serverSocket = ServerSocketChannel.open();
    serverSocket.bind(new InetSocketAddress("localhost", port));
    serverSocket.configureBlocking(false);
    serverSocket.register(this.selectorServer, SelectionKey.OP_ACCEPT);
    this.hostId = serverHostId;
  }

  private boolean tryAcceptClient() throws IOException { // Accept only one client.
      this.selectorServer.selectNow();
      Set<SelectionKey> keys = this.selectorServer.selectedKeys();
      Iterator<SelectionKey> iter = keys.iterator();
      if (!iter.hasNext()) { return false; }
      SelectionKey key = iter.next();
      ServerSocketChannel serverSocket = (ServerSocketChannel)key.channel();
      this.socketServer = serverSocket.accept();
      serverSocket.close();
      this.selectorServer.close();
      this.selectorServer = Selector.open();
      this.socketServer.configureBlocking(false);
      this.socketServer.register(this.selectorServer, SelectionKey.OP_READ);
      this.connected = true;
      return true;
  }

  public void writeSocketServer(String data) throws IOException {
    if (!isConnected() && !tryAcceptClient()) { return; }
    writeSocket(this.socketServer, this.sendCacheServer, data);
  }

  public ArrayList<String> readSocketServer() throws IOException {
    if (!isConnected() && !tryAcceptClient()) { return new ArrayList<String>(); }
    return readSocket(this.selectorServer, this.socketServer, this.recvCacheServer);
  }

  public void stopSyncAsServer() {
    if (this.socketServer != null) {
      try { this.socketServer.close(); }
      catch (Exception e) { System.err.println(e.toString()); }
      this.socketServer = null;
    }
    if (this.selectorServer != null) {
      try { this.selectorServer.close(); }
      catch (Exception e) { System.err.println(e.toString()); }
      this.selectorServer = null;
    }
    this.sendCacheServer.reset();
    this.recvCacheServer.reset();
    this.hostId = singleHostId;
    this.connected = false;
  }

  public void startSyncAsClient() throws IOException {
    // ProcessBuilder builder = new ProcessBuilder(javaBin, "-cp", classpath, className);
    this.socketClient = SocketChannel.open();
    this.socketClient.configureBlocking(false);
    this.socketClient.connect(new InetSocketAddress("localhost", port));
    this.hostId = clientHostId;
  }

  private boolean tryConnectServer() throws IOException {
    this.connected = this.socketClient.finishConnect();
    return this.connected;
  }

  public void writeSocketClient(String data) throws IOException {
    if (!isConnected() && !tryConnectServer()) { return; }
    writeSocket(this.socketClient, this.sendCacheClient, data);
  }

  public ArrayList<String> readSocketClient() throws IOException {
    if (!isConnected() && !tryConnectServer()) { return new ArrayList<String>(); }
    return readSocket(this.selectorClient, this.socketClient, this.recvCacheClient);
  }

  public void stopSyncAsClient() {
    if (this.socketClient != null) {
      try { this.socketClient.close(); }
      catch (Exception e) { System.err.println(e.toString()); }
      this.socketClient = null;
    }
    if (this.selectorClient != null) {
      try { this.selectorClient.close(); }
      catch (Exception e) { System.err.println(e.toString()); }
      this.selectorClient = null;
    }
    this.sendCacheClient.reset();
    this.recvCacheClient.reset();
    this.hostId = singleHostId;
    this.connected = false;
  }

  public void writeSocket(SocketChannel socket, Cache cache, String data) throws IOException {
    cache.data = cache.data + data + messageDelim;
    if (!cache.buffer.hasRemaining()) {
      cache.buffer.clear();
      cache.buffer.put(cache.data.getBytes());
      cache.buffer.flip();
      cache.data = "";
    }
    for (int i = 0; cache.buffer.hasRemaining() &&  i < 8; ++i) {
      socket.write(cache.buffer);
    }
  }

  public ArrayList<String> readSocket(Selector selector, SocketChannel socket, Cache cache) throws IOException {
    ArrayList<String> res = new ArrayList<String>();
    selector.selectNow();
    Set<SelectionKey> keys = selector.selectedKeys();
    Iterator<SelectionKey> iter = keys.iterator();
    int numKey = 0;
    while (iter.hasNext()) {
      ++numKey;
      int bytesRead = socket.read(cache.buffer);
      if (bytesRead == -1) {
        System.err.println("socket eof");
      } else {
        System.err.println("socket read bytes: " + bytesRead);
      }
      iter.remove();
    }
    System.err.println("number of selected keys = " + numKey);
    cache.buffer.flip();
    byte[] bytes;
    if (cache.buffer.hasArray()) {
      bytes = cache.buffer.array();
      System.err.println("buffer has array");
    } else {
      bytes = new byte[cache.buffer.remaining()];
      cache.buffer.get(bytes);
    }
    // Note:
    // Only ascii characters are used.
    // So the byte array can always be converted into a String.
    cache.data = cache.data + new String(bytes);
    cache.buffer.clear();
    boolean cacheLast = !cache.data.endsWith(messageDelim);
    String[] messages = cache.data.split(Pattern.quote(messageDelim));
    cache.data = "";
    int numMessages = messages.length;
    if (numMessages <= 0) { return res; }
    if (cacheLast) {
      numMessages -= 1;
      cache.data = messages[numMessages];
    }
    if (numMessages <= 0) { return res; }
    for (int i = 0; i < numMessages; ++i) { res.add(messages[i]); }
    return res;
  }
}
