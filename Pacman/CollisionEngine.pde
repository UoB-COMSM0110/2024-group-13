// Class for detecting and solving collisions between items.
public class CollisionEngine {
  public static void solveCollisions(GameInfo gInfo,
      ArrayList<SynchronizedItem> items) {
    SimpleCollisionEngine.solveCollisions(gInfo, items);
  }
}


// Post-collision detection.
// Very primal position correction.
// No passing-through detection.
// No collision order calculation.
public class SimpleCollisionEngine {
  // Solve all collisions between items.
  public static void solveCollisions(GameInfo gInfo,
      ArrayList<SynchronizedItem> items) {
    ArrayList<MovableItem> movableItems = new ArrayList<MovableItem>();
    for (SynchronizedItem item : items) {
      if (item instanceof MovableItem) {
        movableItems.add(item);
      }
    }
    movableItems.forEach((item) -> { solveCollisionsForItem(gInfo, item, items); });
  }

  // Solve collisions between a specific item and other items.
  public static void solveCollisionsForItem(GameInfo gInfo, MovableItem item,
      ArrayList<SynchronizedItem> items) {
    for (SynchronizedItem target : items) {
      if (item == target) {
        continue;
      }
      if (areOverlap(item, target)) {
        correctPosition(item, target);
        item.onCollisionWith(gInfo, target);
        if (!(target instanceof MovableItem)) {
          target.onCollisionWith(gInfo, item);
        }
      }
    }
  }

  // Currently only works for rectangular items.
  public static boolean areOverlap(SynchronizedItem item, SynchronizedItem target) {
    return item.getX() < target.getX() + target.getW() &&
      target.getX() < item.getX() + item.getW() &&
      item.getY() < target.getY() + target.getH() &&
      target.getY() < item.getY() + item.getW();
  }

  // Correct the position of the movable item.
  public static void correctPosition(MovableItem item, SynchronizedItem target) {
    switch (item.getDirection()) {
      case UPWARD: { // item top <- target bottom
        item.setY(target.getY() + target.getH());
        break;
      }
      case RIGHTWARD: { // item right <- target left
        item.setX(target.getX() - item.getW());
        break;
      }
      case DOWNWARD: { // item bottom <- target top
        item.setY(target.getY() - item.getH());
        break;
      }
      case LEFTWARD: { // item left <- target right
        item.setX(target.getX() + target.getW());
        break;
      }
    }
  }
}
