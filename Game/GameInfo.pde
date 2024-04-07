import java.io.IOException;
import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.NetworkInterface;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

// https://jenkov.com/tutorials/java-nio/selectors.html
// https://www.baeldung.com/java-nio-selector

static final int KB = 1024;
static final int MB = 1024 * KB;

static final int singleHostId = 0;
static final int serverHostId = 1;
static final int clientHostId = 2;

final int port = 2024;

final int bufferSize = 2 * MB;
final String messageDelim = "[MSGEOF]";


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
  private boolean connectedToClient;
  private boolean connectedToServer;

  private float windowWidth, windowHeight;
  private float mapWidth, mapHeight;
  // Coefficients used to transform sync-coordinates to local-coordinates.
  private float mapScaleX, mapScaleY;
  private float mapOffsetX, mapOffsetY;

  private int frameRateConfig;
  private long gameStartTimeMs;
  private long currentFrameTimeMs;
  private long lastFrameIntervalMs;

  private long lastEvolveTimeMs;

  private String playerName1;
  private String playerName2;
  private int playerScore1;
  private int playerScore2;
  private boolean networkSessionClosing;

  private Selector selectorServer;
  private ServerSocketChannel listenerServer;
  private SocketChannel socketServer;
  private Cache sendCacheServer;
  private Cache recvCacheServer;

  private Selector selectorClient;
  private SocketChannel socketClient;
  private Cache sendCacheClient;
  private Cache recvCacheClient;

  public GameInfo() {
    System.out.println("ip: " + getIpAddr());

    this.hostId = singleHostId;
    this.connectedToClient = false;
    this.connectedToServer = false;

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
    this.lastEvolveTimeMs = 0;

    this.playerName1 = "Anonym1";
    this.playerName2 = "Anonym2";
    this.playerScore1 = 0;
    this.playerScore2 = 0;

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
  public void setPlayerScore1(int score) { this.playerScore1 = score; }
  public void setPlayerScore2(int score) { this.playerScore2 = score; }

  public void update() {
    long lastFrameTimeMs = this.currentFrameTimeMs;
    this.currentFrameTimeMs = System.currentTimeMillis();
    if (frameCount > 1) {
      this.lastFrameIntervalMs = this.currentFrameTimeMs - lastFrameTimeMs;
    }
  }

  public int getHostId() { return this.hostId; }
  public boolean isSingleHost() { return this.hostId == singleHostId; }
  public boolean isClientHost() { return this.hostId == clientHostId; }
  public boolean isServerHost() { return this.hostId == serverHostId; }

  public boolean isConnectedToClient() { return this.connectedToClient; }
  public boolean isConnectedToServer() { return this.connectedToServer; }

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

  public long getLastEvolveTimeMs() { return this.lastEvolveTimeMs; }
  public void resetEvolveTime() { this.lastEvolveTimeMs = 0; }
  public void updateEvolveTime() { this.lastEvolveTimeMs = this.currentFrameTimeMs; }
  public long getLastEvolveIntervalMs() {
    if (this.lastEvolveTimeMs <= 0) { return 0; }
    else { return this.currentFrameTimeMs - this.lastEvolveTimeMs; }
  }
  public float getLastEvolveIntervalS() { return getLastEvolveIntervalMs() / 1000.0; }

  public String getPlayerName1() { return this.playerName1; }
  public String getPlayerName2() { return this.playerName2; }
  public int getPlayerScore1() { return this.playerScore1; }
  public int getPlayerScore2() { return this.playerScore2; }

  public void startSyncAsServer() {
    try {
      this.selectorServer = Selector.open();
      this.listenerServer = ServerSocketChannel.open();
      this.listenerServer.socket().setReuseAddress(true);
      this.listenerServer.configureBlocking(false);
      this.listenerServer.bind(new InetSocketAddress("localhost", port));
      this.listenerServer.register(this.selectorServer, SelectionKey.OP_ACCEPT);
      this.hostId = serverHostId;
      page.onSyncStart();
    } catch (Exception e) {
      onNetworkFailure("startSyncAsServer", e);
    }
  }

  // Accept only one client.
  private boolean tryAcceptClient() {
    if (this.connectedToClient) { return true; }
    if (this.selectorServer == null) { return false; }
    try {
      this.selectorServer.selectNow();
      Set<SelectionKey> keys = this.selectorServer.selectedKeys();
      Iterator<SelectionKey> iter = keys.iterator();
      while (iter.hasNext()) {
        SelectionKey key = iter.next();
        iter.remove();
        if (!key.isValid()) { continue; }
        if (!key.isAcceptable()) { continue; }
        this.socketServer = this.listenerServer.accept();
        Socket socket = this.socketServer.socket();
        socket.setReuseAddress(true);
        System.out.println("client from: " + socket.getRemoteSocketAddress().toString());
        this.socketServer.configureBlocking(false);
        this.socketServer.register(this.selectorServer, SelectionKey.OP_READ);
        this.connectedToClient = true;
        page.onConnectionStart();
        return true;
      }
      return false;
    } catch (Exception e) {
      onNetworkFailure("tryAcceptClient", e);
      return false;
    }
  }

  public boolean isServerSendBufferFull() {
    return this.sendCacheServer.data.length() > bufferSize / 2;
  }
  public boolean isServerSendBufferEmpty() {
    return this.sendCacheServer.data.length() == 0 &&
      !this.sendCacheServer.buffer.hasRemaining();
  }

  public void writeSocketServer(String data) {
    if (!isConnectedToClient() && !tryAcceptClient()) { return; }
    writeSocket(this.socketServer, this.sendCacheServer, data);
  }

  public ArrayList<String> readSocketServer() {
    if (!isConnectedToClient() && !tryAcceptClient()) { return new ArrayList<String>(); }
    return readSocket(this.selectorServer, this.socketServer, this.recvCacheServer);
  }

  public void stopSyncAsServer() {
    if (this.listenerServer != null) {
      try { this.listenerServer.close(); }
      catch (Exception e) { System.err.println("when stoping sync as server: " + e.toString()); }
      this.listenerServer = null;
    }
    if (this.socketServer != null) {
      try { this.socketServer.close(); }
      catch (Exception e) { System.err.println("when stoping sync as server: " + e.toString()); }
      this.socketServer = null;
    }
    if (this.selectorServer != null) {
      try { this.selectorServer.close(); }
      catch (Exception e) { System.err.println("when stoping sync as server: " + e.toString()); }
      this.selectorServer = null;
    }
    this.sendCacheServer.reset();
    this.recvCacheServer.reset();
    this.hostId = singleHostId;
    this.connectedToClient = false;
    page.onConnectionClose();
  }

  public void startSyncAsClient() {
    try {
      // ProcessBuilder builder = new ProcessBuilder(javaBin, "-cp", classpath, className);
      this.socketClient = SocketChannel.open();
      this.socketClient.configureBlocking(false);
      this.socketClient.connect(new InetSocketAddress("172.23.25.12", port));
      this.hostId = clientHostId;
      page.onSyncStart();
    } catch (Exception e) {
      onNetworkFailure("startSyncAsClient", e);
    }
  }

  private boolean tryConnectServer() {
    if (this.connectedToServer) { return true; }
    if (this.socketClient == null) { return false; }
    try {
      if (!this.socketClient.finishConnect()) { return false; }
      this.selectorClient = Selector.open();
      this.socketClient.register(this.selectorClient, SelectionKey.OP_READ);
      this.connectedToServer = true;
      page.onConnectionStart();
      return true;
    } catch (Exception e) {
      onNetworkFailure("tryConnectServer", e);
      return false;
    }
  }

  public void writeSocketClient(String data) {
    if (!isConnectedToServer() && !tryConnectServer()) { return; }
    writeSocket(this.socketClient, this.sendCacheClient, data);
  }

  public ArrayList<String> readSocketClient() {
    if (!isConnectedToServer() && !tryConnectServer()) { return new ArrayList<String>(); }
    return readSocket(this.selectorClient, this.socketClient, this.recvCacheClient);
  }

  public void stopSyncAsClient() {
    if (this.socketClient != null) {
      try { this.socketClient.close(); }
      catch (Exception e) { System.err.println("when stoping sync as client: " + e.toString()); }
      this.socketClient = null;
    }
    if (this.selectorClient != null) {
      try { this.selectorClient.close(); }
      catch (Exception e) { System.err.println("when stoping sync as client: " + e.toString()); }
      this.selectorClient = null;
    }
    this.sendCacheClient.reset();
    this.recvCacheClient.reset();
    this.hostId = singleHostId;
    this.connectedToServer = false;
    page.onConnectionClose();
  }

  public void writeSocket(SocketChannel socket, Cache cache, String data) {
    if (data != null) {
      cache.data = cache.data + data + messageDelim;
    }
    try {
      if (!cache.buffer.hasRemaining() && 0 < cache.data.length()) {
        cache.buffer.clear();
        cache.buffer.put(cache.data.getBytes());
        cache.buffer.flip();
        cache.data = "";
      }
      for (int i = 0; cache.buffer.hasRemaining() &&  i < 8; ++i) {
        socket.write(cache.buffer);
      }
    } catch (Exception e) {
      onNetworkFailure("writeSocket", e);
    }
  }

  public ArrayList<String> readSocket(Selector selector, SocketChannel socket, Cache cache) {
    ArrayList<String> res = new ArrayList<String>();
    try {
      selector.selectNow();
      Set<SelectionKey> keys = selector.selectedKeys();
      Iterator<SelectionKey> iter = keys.iterator();
      while (iter.hasNext()) {
        SelectionKey key = iter.next();
        iter.remove();
        if (!key.isValid()) { continue; }
        if (!key.isReadable()) { continue; }
        int bytesRead = socket.read(cache.buffer);
      }
      cache.buffer.flip();
      int dataLen = cache.buffer.remaining();
      byte[] bytes;
      if (cache.buffer.hasArray()) {
        bytes = cache.buffer.array();
        System.out.println("buffer has array");
      } else {
        bytes = new byte[dataLen];
        cache.buffer.get(bytes);
      }
      // Note: Ascii character array can always be converted into a String.
      cache.data = cache.data + new String(bytes, 0, dataLen);
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
    } catch (Exception e) {
      onNetworkFailure("readSocket", e);
      return res;
    }
  }

  public void onNetworkFailure(String where, Exception e) {
    System.err.println(where + " : " + e.toString());
    page.onNetworkFailure(where, e);
    if (gameInfo.isServerHost()) { gameInfo.stopSyncAsServer(); }
    if (gameInfo.isClientHost()) { gameInfo.stopSyncAsClient(); }
  }
}

public static String getIpAddr() {
  List<String> allIps = getAllIpAddr();
  if (allIps.size() <= 0) { return null; }
  return allIps.get(0);
}

public static List<String> getAllIpAddr() {
  ArrayList<String> res = new ArrayList<String>();
  try {
    Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
    if (interfaces == null) { return res; }
    while (interfaces.hasMoreElements()) {
      NetworkInterface iface = interfaces.nextElement();
      if (iface.isLoopback() || !iface.isUp()) { continue; } // No loopback addresses.
      Enumeration<InetAddress> enumIpAddr = iface.getInetAddresses();
      while (enumIpAddr.hasMoreElements()) {
        InetAddress addr = enumIpAddr.nextElement();
        if (addr instanceof Inet6Address) { continue; } // No ipv6 addresses.
        res.add(addr.getHostAddress());
      }
    }
  } catch (Exception e) {
    System.err.println("error retrieving network interface list");
  }
  System.out.println("all ip addresses: " + res);
  return res;
}
