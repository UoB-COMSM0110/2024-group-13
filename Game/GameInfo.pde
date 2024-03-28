import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;

// https://jenkov.com/tutorials/java-nio/selectors.html
// https://www.baeldung.com/java-nio-selector

static final int singleHostId = 0;
static final int serverHostId = 1;
static final int clientHostId = 2;

final int port = 2024;
final int bufferSize = 2 * 1024 * 1024; // 2MB

// GameInfo holds some housekeeping information.
// For example, the size of the window, the ip/port of the other player, etc.
public class GameInfo {
  private int hostId;

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

  private Selector selector;
  private SocketChannel socket;
  private ByteBuffer buffer;

  public GameInfo() {
    this.hostId = singleHostId;

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

    this.buffer = ByteBuffer.allocate(bufferSize);
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

  public boolean hasConnection() { return this.socket == null; }

  public boolean startSyncAsServer() {
    try {
      this.selector = Selector.open();

      ServerSocketChannel serverSocket = ServerSocketChannel.open()
      serverSocket.bind(new InetSocketAddress("localhost", port));
      serverSocket.configureBlocking(false);
      serverSocket.register(this.selector, SelectionKey.OP_ACCEPT);
    } catch (Exception e) {
      System.err.println(e.toString());
      return false;
    }
    this.hostId = serverHostId;
    return true;
  }

  private boolean tryAcceptClient() { // Accept only one client.
    this.selector.selectNow();
    Set<SelectionKey> keys = this.selector.selectedKeys();
    Iterator<SelectionKey> iter = keys.iterator();
    if (!iter.hasNext()) { return false; }
    Selection key = iter.next();
    ServerSocketChannel serverSocket = key.channel();
    this.socket = serverSocket.accept();
    serverSocket.close();
    this.selector.close();
    this.selector = Selector.open();
    this.socket.configureBlocking(false);
    this.socket.register(this.selector, SelectionKey.OP_READ);
    return true;
  }

  public boolean tryServerWriteSocket() {
    if (!hasConnection() && !tryAcceptClient()) { return false; }
    return tryWriteSocket();
  }
  public boolean tryServerReadSocket() {
    if (!hasConnection() && !tryAcceptClient()) { return false; }
    return tryReadSocket();
  }

  public boolean startSyncAsClient() {
    // ProcessBuilder builder = new ProcessBuilder(javaBin, "-cp", classpath, className);
    this.socket = SocketChannel.open(new InetSocketAddress("localhost", port));
    this.hostId = clientHostId;
    return false;
  }

  public boolean tryWriteSocket() {
    this.socket.write(this.buffer);
    this.buffer.clear();
  }

  public boolean tryReadSocket() {
    this.selector.selectNow();
    Set<SelectionKey> keys = this.selector.selectedKeys();
    Iterator<SelectionKey> iter = keys.iterator();
    int i = 0;
    while (iter.hasNext()) {
      System.err.println("number of selected keys = " + ++i);
      int r = this.socket.read(this.buffer);
      if (r == -1) {
        System.err.println("socket reading error");
      }
      iter.remove();
    }
    this.buffer.clear();
    new String(this.buffer.array()).trim();
    return true;
  }

  public boolean stopSync() {
    if (this.socket != null) { this.socket.close(); this.socket = null; }
    if (this.selector != null) { this.selector.close(); this.selector = null; }
    this.buffer.clear();
    this.hostId = singleHostId;
  }
}
