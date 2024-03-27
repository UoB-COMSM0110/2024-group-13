import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketAddress;
import java.nio.channels.ServerSocketChannel;

static final int singleHostId = 0;
static final int serverHostId = 1;
static final int clientHostId = 2;

final int port = 2024;

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

  private ServerSocket serverSocket;
  private Socket socket;

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
      InetAddress hostIp = InetAddress.getLocalHost();
      System.out.println("ip of local host: " + hostIp.getHostAddress());
      this.serverSocket = new ServerSocket(port);
      SocketAddress serverAddr = this.serverSocket.getLocalSocketAddress();
      System.out.println("ip of server: " + serverAddr.toString());
      this.serverSocket.close();

      this.hostId = serverHostId;
      return true;
    } catch (Exception e) {
      System.err.println(e.toString());
      return false;
    }
  }
}
