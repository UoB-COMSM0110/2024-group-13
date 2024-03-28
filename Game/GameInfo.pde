import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;

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

  private ServerSocketChannel serverSocket;
  private Selector selector;
  private SocketChannel client;
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

  public boolean startServerListening() {
    try {
      this.serverSocket = ServerSocketChannel.open()
      this.serverSocket.bind(new InetSocketAddress("localhost", port));
      this.serverSocket.configureBlocking(false);
      this.selector = Selector.open();
      this.serverSocket.register(this.selector, SelectionKey.OP_ACCEPT);
    } catch (Exception e) {
      System.err.println(e.toString());
      return false;
    }
    this.hostId = serverHostId;
    return true;
  }

  public boolean stopServer() {
    this.selector.close();
    this.serverSocket.close();
    this.buffer.clear();
    this.hostId = singleHostId;
  }

  public boolean readSever() {
    this.selector.select();
    Set<SelectionKey> keys = this.selector.selectedKeys();
    Iterator<SelectionKey> iter = keys.iterator();
    while (iter.hasNext()) {
      Selection key = iter.next();
      if (key.isAcceptable()) {
        SocketChannel client = this.serverSocket.accept();
        client.configureBlocking(false);
        client.register(this.selector, SelectionKey.OP_READ);
      } else if (key.isReadable()) {
        SocketChannel client = key.channel();
        int r = client.read(this.buffer);
        if (r == -1 || new String(this.buffer.array()).trim().equals(POISON_PILL)) { client.close();
          System.err.println("client closed");
        } else {
          this.buffer.flip();
          client.write(this.buffer);
          this.buffer.clear();
        }
      }
      iter.remove();
    }
    // selector, client, serverSocket .close()
  }

  // ProcessBuilder builder = new ProcessBuilder(javaBin, "-cp", classpath, className);
}
