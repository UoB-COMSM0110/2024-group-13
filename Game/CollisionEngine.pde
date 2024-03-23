// Class for detecting and solving collisions between items.
public class CollisionEngine {
  public void solveCollisions() {
    (new SimpleCollisionEngine()).solveCollisions();
  }
}


// Post-collision detection.
// No passing-through detection.
// No collision order calculation.
// No multiple-object collision.
public class SimpleCollisionEngine {
  // Solve all collisions between items.
  public void solveCollisions() {
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
      solveCollisionsForItem(item, settled);
      settled.add(item);
    }
  }

  // Solve collisions between a specific item and other items.
  public void solveCollisionsForItem(MovableItem item, ArrayList<SynchronizedItem> targets) {
    for (SynchronizedItem target : targets) {
      if (isOverlap(item, target)) {
        target.onCollisionWith(item);
      }
    }
  }

  // Currently only works for rectangular items.
  public boolean isOverlap(SynchronizedItem item, SynchronizedItem target) {
    return item.getLeftX() < target.getRightX() && target.getLeftX() < item.getRightX() &&
      item.getTopY() < target.getBottomY() && target.getTopY() < item.getBottomY();
  }
}
