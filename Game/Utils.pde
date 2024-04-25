static final float epsilon = 0.02;


@FunctionalInterface
public static interface Action {
  void run();
}


@FunctionalInterface
public static interface Condition {
  boolean eval();
}


public class Timer {
  private float intervalS;
  private Action action;
  private boolean repeated;
  private long nextRunTimeMs;

  public Timer(float intervalS, Action action) {
    this(intervalS, intervalS, action);
  }

  public Timer(float offsetS, float intervalS, Action action) {
    this.intervalS = intervalS;
    this.action = action;
    this.repeated = intervalS > 0.0 ? true : false;
    this.nextRunTimeMs = gameInfo.getFrameTimeMs() + (long)(offsetS * 1000.0);
  }

  public boolean due() {
    return gameInfo.getFrameTimeMs() >= this.nextRunTimeMs && !expired();
  }

  public void run() {
    if (this.action != null) { this.action.run(); }
    if (this.repeated) {
      this.nextRunTimeMs = gameInfo.getFrameTimeMs() + (long)(this.intervalS * 1000.0);
    } else {
      this.nextRunTimeMs = 0;
    }
  }

  public boolean expired() {
    return this.nextRunTimeMs <= 0;
  }

  public void destroy() {
    this.nextRunTimeMs = 0;
  }
}


public class OneOffTimer extends Timer {
  public OneOffTimer(float offsetS, Action action) {
    super(offsetS, 0.0, action);
  }
}


public void drawTextWithOutline(String text, float x, float y, float textSize, int outlineOffset,
    color textColor) {
  textFont(fontMinecraft);
  textSize(textSize);

  // Draw the outline
  fill(116, 54, 18); 
  for (int dx = -outlineOffset; dx <= outlineOffset; dx++) {
    for (int dy = -outlineOffset; dy <= outlineOffset; dy++) {
      if (dx != 0 || dy != 0) { 
        text(text, x + dx, y + dy);
      }
    }
  }

  fill(textColor); 
  text(text, x, y);
}
