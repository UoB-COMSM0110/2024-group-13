// Class for detecting and solving collisions between items.
public static class CollisionEngine {
  public static void solveCollisions(GameInfo gInfo, Page page) {
    SimpleCollisionEngine.solveCollisions(gInfo, Page page);
  }
}


// Post-collision detection.
// No passing-through detection.
// No collision order calculation.
// No multiple-object collision.
public static class SimpleCollisionEngine {
  // Solve all collisions between items.
  public static void solveCollisions(GameInfo gInfo, Page page) {
    ArrayList<SynchronizedItem> settled = new ArrayList<SynchronizedItem>();
    ArrayList<MovableItem> unsettled = new ArrayList<MovableItem>();
    for (SynchronizedItem item : page.getSyncItems()) {
      if (item instanceof MovableItem) {
        unsettled.add((MovableItem)item);
      } else {
        settled.add(item);
      }
    }
    while (unsettled.size() > 0) {
      MovableItem item = unsettled.remove(unsettled.size() - 1);
      solveCollisionsForItem(gInfo, page, item, settled);
      settled.add(item);
    }
  }

  // Solve collisions between a specific item and other items.
  public static void solveCollisionsForItem(GameInfo gInfo, Page page,
      MovableItem item, ArrayList<SynchronizedItem> items) {
    for (SynchronizedItem target : items) {
      if (isOverlap(item, target)) {
        float dx = getXCorrection(item, target);
        float dy = getYCorrection(item, target);
        item.onCollisionWith(gInfo, page, target, dx, dy);
      }
    }
  }

  // Currently only works for rectangular items.
  public static boolean isOverlap(SynchronizedItem item, SynchronizedItem target) {
    return item.getX() < target.getX() + target.getW() &&
      target.getX() < item.getX() + item.getW() &&
      item.getY() < target.getY() + target.getH() &&
      target.getY() < item.getY() + item.getW();
  }

  // The x correction needed to avoid overlapping.
  public static float getXCorrection(MovableItem item, SynchronizedItem target) {
    switch (item.getDirection()) {
      // item right <- target left
      case RIGHTWARD: return target.getX() - item.getW() - item.getX();
        // item left <- target right
      case LEFTWARD: return target.getX() + target.getW() - item.getX();
      default: return 0.0;
    }
  }

  // The y correction needed to avoid overlapping.
  public static float getYCorrection(MovableItem item, SynchronizedItem target) {
    switch (item.getDirection()) {
      // item top <- target bottom
      case UPWARD: return target.getY() + target.getH() - item.getY();
        // item bottom <- target top
      case DOWNWARD: return target.getY() - item.getH() - item.getY();
      default: return 0.0;
    }
  }
}
