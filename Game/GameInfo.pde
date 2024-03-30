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

  private Selector selectorServer;
  private SocketChannel socketServer;
  private ByteBuffer bufferServer;
  private Selector selectorClient;
  private SocketChannel socketClient;
  private ByteBuffer bufferClient;

  private ArrayList<String> messages;
  private String partMessage;

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

    this.bufferServer = ByteBuffer.allocate(bufferSize);
    this.bufferClient = ByteBuffer.allocate(bufferSize);

    this.bufferClient = ByteBuffer.allocate(bufferSize);
    this.messages = new ArrayList<String>();
    this.partMessage = "";
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

  public boolean startSyncAsServer() {
    try {
      this.selectorServer = Selector.open();
      ServerSocketChannel serverSocket = ServerSocketChannel.open()
      serverSocket.bind(new InetSocketAddress("localhost", port));
      serverSocket.configureBlocking(false);
      serverSocket.register(this.selectorServer, SelectionKey.OP_ACCEPT);
    } catch (Exception e) {
      System.err.println(e.toString());
      return false;
    }
    this.hostId = serverHostId;
    return true;
  }

  private boolean tryAcceptClient() { // Accept only one client.
    try {
      this.selectorServer.selectNow();
      Set<SelectionKey> keys = this.selectorServer.selectedKeys();
      Iterator<SelectionKey> iter = keys.iterator();
      if (!iter.hasNext()) { return false; }
      Selection key = iter.next();
      ServerSocketChannel serverSocket = key.channel();
      this.socketServer = serverSocket.accept();
      serverSocket.close();
      this.selectorServer.close();
      this.selectorServer = Selector.open();
      this.socketServer.configureBlocking(false);
      this.socketServer.register(this.selectorServer, SelectionKey.OP_READ);
    } catch (Exception e) {
      System.err.println(e.toString());
      return false;
    }
    return true;

    // while(!socketChannel.finishConnect());
  }

  public boolean tryWriteSocketServer(String data) {
    if (this.socketServer == null && !tryAcceptClient()) { return false; }
    return tryWriteSocket(this.socketServer, this.bufferServer, data);
  }

  public String tryReadSocketServer() {
    if (this.socketClient == null && !tryAcceptClient()) { return null; }
    return tryReadSocket(this.selectorServer, this.socketServer, this.bufferServer);
  }

  public boolean stopSyncAsServer() {
    if (this.socketServer != null) {
      this.socketServer.close();
      this.socketServer = null;
    }
    this.selectorServer.close();
    this.selectorServer = null;
    this.bufferServer.clear();
    this.hostId = singleHostId;
  }

  public boolean startSyncAsClient() {
    // ProcessBuilder builder = new ProcessBuilder(javaBin, "-cp", classpath, className);
    try {
      this.socketClient = SocketChannel.open(new InetSocketAddress("localhost", port));
    } catch (Exception e) {
      System.err.println(e.toString());
      return false;
    }
    this.hostId = clientHostId;
    return false;
  }

  public boolean tryWriteSocketClient(String data) {
    return tryWriteSocket(this.socketClient, this.bufferClient, data);
  }

  public String tryReadSocketClient() {
    return tryReadSocket(this.selectorClient, this.socketClient, this.bufferClient);
  }

  public boolean stopSyncAsClient() {
    this.socketClient.close();
    this.socketClient = null;
    this.selectorClient.close();
    this.selectorClient = null;
    this.bufferClient.clear();
    this.hostId = singleHostId;
  }

  public boolean tryWriteSocket(SocketChannel socket, ByteBuffer buffer, String data) {
    buffer.clear();
    buffer.put(data.getBytes());
    buffer.flip();
    while (buffer.remaining() > 0) {
      socket.write(buffer);
    }
  }

  public String tryReadSocket(Selector selector, SocketChannel socket, ByteBuffer buffer) {
    buffer.clear();
    selector.selectNow();
    Set<SelectionKey> keys = selector.selectedKeys();
    Iterator<SelectionKey> iter = keys.iterator();
    int numKey = 0;
    while (iter.hasNext()) {
      ++numKey;
      int bytesRead = socket.read(buffer);
      if (bytesRead == -1) {
        System.err.println("socket eof");
      } else {
        System.err.println("socket read bytes: " + bytesRead);
      }
      iter.remove();
    }
    System.err.println("number of selected keys = " + numKey);
    buffer.flip();
    byte[] bytes;
    if (buffer.hasArray()) {
      bytes = buffer.array();
      System.err.println("buffer has array");
    } else {
      bytes = new byte[buffer.remaining()];
      buffer.get(bytes);
    }
    // Notes: Only ascii characters are used,
    // so the byte array always can be converted into a String.
    this.partMessage += new String(bytes);
    return data;
  }
}
