// GameInfo holds some housekeeping information.
// For example, the size of the window, the ip/port of the other player, etc.
public class GameInfo {
  // Coefficients used to transform sync-coordinates to local-coordinates.
  private float mapScaleX;
  private float mapScaleY;
  private float mapOffsetX;
  private float mapOffsetY;

  private int frameRateConfig;
  private long gameStartTimeMs;
  private int currentFrameCount;
  private long currentFrameTimeMs;
  private int lastFrameIntervalMs;

  public GameInfo() {
    mapScaleX = 1.0;
    mapScaleY = 1.0;
    mapOffsetX = 0.0;
    mapOffsetY = 0.0;

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

  public float getMapScaleX() { return mapScaleX; }
  public float getMapScaleY() { return mapScaleY; }
  public float getMapOffsetX() { return mapOffsetX; }
  public float getMapOffsetY() { return mapOffsetY; }

  public int getFrameRateConfig() { return frameRateConfig; }
  public long getLastFrameIntervalMs() { return lastFrameIntervalMs; }
  public float getLastFrameIntervalS() { return getLastFrameIntervalMs() / 1000.0; }
}
