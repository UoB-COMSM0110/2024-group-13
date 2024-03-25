static final int serverHostId = 1;
static final int clientHostId = 2;

// GameInfo holds some housekeeping information.
// For example, the size of the window, the ip/port of the other player, etc.
public class GameInfo {
  private ArrayList<Timer> timers;

  private int hostId;

  // Coefficients used to transform sync-coordinates to local-coordinates.
  private float mapScaleX, mapScaleY;
  private float mapOffsetX, mapOffsetY;
  private float mapWidth, mapHeight;

  private int frameRateConfig;
  private long gameStartTimeMs;
  private int currentFrameCount;
  private long currentFrameTimeMs;
  private int lastFrameIntervalMs;

  public GameInfo() {
    this.hostId = 0;

    this.mapScaleX = 1.0;
    this.mapScaleY = 1.0;
    this.mapOffsetX = 0.0;
    this.mapOffsetY = 0.0;

    this.mapWidth = 800.0;
    this.mapHeight = 600.0;

    this.frameRateConfig = 50;
    this.gameStartTimeMs = System.currentTimeMillis();
  }

  public void update() {
    currentFrameCount += 1;
    long lastFrameTimeMs = this.currentFrameTimeMs;
    this.currentFrameTimeMs = System.currentTimeMillis();
    if (currentFrameCount > 1) {
      lastFrameIntervalMs = (int)(this.currentFrameTimeMs - lastFrameTimeMs);
    }
  }

  public int getHostId() { return this.hostId; }

  public float getMapScaleX() { return this.mapScaleX; }
  public float getMapScaleY() { return this.mapScaleY; }
  public float getMapOffsetX() { return this.mapOffsetX; }
  public float getMapOffsetY() { return this.mapOffsetY; }

  public float getMapWidth() { return this.mapWidth; }
  public float getMapHeight() { return this.mapHeight; }

  public int getFrameRateConfig() { return this.frameRateConfig; }
  public long getLastFrameIntervalMs() { return this.lastFrameIntervalMs; }
  public float getLastFrameIntervalS() { return this.getLastFrameIntervalMs() / 1000.0; }
  public long getFrameTimeMs() { return this.currentFrameTimeMs; }
}
