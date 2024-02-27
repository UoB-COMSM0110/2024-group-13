// GameInfo holds some housekeeping information.
// For example, the size of the window, the ip/port of the other player, etc.
public class GameInfo {
  // Coefficients used to transform sync-coordinates to local-coordinates.
  private float syncCoordScaleX;
  private float syncCoordScaleY;
  private float syncCoordOffsetX;
  private float syncCoordOffsetY;

  public GameInfo() {
    syncCoordScaleX = 1.0;
    syncCoordScaleY = 1.0;
    syncCoordOffsetX = 0.0;
    syncCoordOffsetY = 0.0;
  }

  public float getSyncCoordScaleX() { return syncCoordScaleX; }
  public float getSyncCoordScaleY() { return syncCoordScaleY; }
  public float getSyncCoordOffsetX() { return syncCoordOffsetX; }
  public float getSyncCoordOffsetY() { return syncCoordOffsetY; }
}
