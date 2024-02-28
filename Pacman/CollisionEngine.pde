// Class for detecting collisions between items.
public class CollisionEngine {
  public static void solveCollisions(GameInfo gInfo,
      ArrayList<SynchronizedItem> items) {
    SimpleCollisionEngine.detectCollisions(gInfo, items);
  }
}


// Post-collision detection.
// No position correction.
// No passing-through detection.
// No collision order calculation.
public class SimpleCollisionEngine {
  public static void detectCollisions(GameInfo gInfo,
      ArrayList<SynchronizedItem> items) {
    ArrayList<MovableItem> movableItems = new ArrayList<MovableItem>();
    for (SynchronizedItem item : items) {
      if (item instanceof MovableItem) {
        movableItems.add(item);
      }
    }
    movableItems.forEach((item) -> { detectCollisionsForItem(gInfo, item, items); });
  }

  public static void detectCollisionsForItem(GameInfo gInfo, MovableItem item,
      ArrayList<SynchronizedItem> items) {
    for (SynchronizedItem otherItem : items) {
      if (item != otherItem) {
        detectCollisionsBetween(GameInfo gInfo, item, otherItem);
      }
    }
  }

  public static void detectCollisionsBetween(GameInfo gInfo,
      SynchronizedItem item1, SynchronizedItem item2) {
  }
}
