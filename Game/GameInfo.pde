static final int serverHostId = 1;
static final int clientHostId = 2;

// GameInfo holds some housekeeping information.
// For example, the size of the window, the ip/port of the other player, etc.
public class GameInfo {
  private int hostId;

  // Coefficients used to transform sync-coordinates to local-coordinates.
  private float mapScaleX;
  private float mapScaleY;
  private float mapOffsetX;
  private float mapOffsetY;

  private float mapWidth;
  private float mapHeight;

  private int frameRateConfig;
  private long gameStartTimeMs;
  private int currentFrameCount;
  private long currentFrameTimeMs;
  private int lastFrameIntervalMs;

  public GameInfo() {
    hostId = 0;

    mapScaleX = 1.0;
    mapScaleY = 1.0;
    mapOffsetX = 0.0;
    mapOffsetY = 0.0;

    mapWidth = 800.0;
    mapHeight = 600.0;

    frameRateConfig = 50;
    gameStartTimeMs = System.currentTimeMillis();
  }

  public void update() {
    currentFrameCount += 1;
    long lastFrameTimeMs = currentFrameTimeMs;
    currentFrameTimeMs = System.currentTimeMillis();
    if (currentFrameCount > 1) {
      lastFrameIntervalMs = (int)(currentFrameTimeMs - lastFrameTimeMs);
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
}
