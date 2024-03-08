// GameInfo holds some housekeeping information.
// For example, the size of the window, the ip/port of the other player, etc.
public class GameInfo {
  // Coefficients used to transform sync-coordinates to local-coordinates.
  private float syncCoordScaleX;
  private float syncCoordScaleY;
  private float syncCoordOffsetX;
  private float syncCoordOffsetY;

  private int frameRateConfig;
  private long gameStartTimeMs;
  private int currentFrameCount;
  private long currentFrameTimeMs;
  private long lastFrameIntervalMs;

  public GameInfo() {
    syncCoordScaleX = 1.0;
    syncCoordScaleY = 1.0;
    syncCoordOffsetX = 0.0;
    syncCoordOffsetY = 0.0;

    frameRateConfig = 50;
    gameStartTimeMs = System.currentTimeMillis();
  }

  public void update() {
    currentFrameCount += 1;
    long lastFrameTimeMs = currentFrameTimeMs;
    currentFrameTimeMs = System.currentTimeMillis();
    lastFrameIntervalMs = currentFrameCount <= 1 ? 0 : (currentFrameTimeMs - lastFrameTimeMs);
  }

  public float getSyncCoordScaleX() { return syncCoordScaleX; }
  public float getSyncCoordScaleY() { return syncCoordScaleY; }
  public float getSyncCoordOffsetX() { return syncCoordOffsetX; }
  public float getSyncCoordOffsetY() { return syncCoordOffsetY; }

  public long getFrameRateConfig() { return frameRateConfig; }
  public long getLastFrameIntervalMs() { return lastFrameIntervalMs; }
}
