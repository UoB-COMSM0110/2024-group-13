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
    ArrayList<SynchronizedItem> checked = new ArrayList<SynchronizedItem>();
    ArrayList<MovableItem> unchecked = new ArrayList<MovableItem>();
    for (SynchronizedItem item : page.getSyncItems()) {
      if (item instanceof MovableItem) {
        unchecked.add((MovableItem)item);
      } else {
        checked.add(item);
      }
    }
    while (unchecked.size() > 0) {
      MovableItem item = unchecked.remove(unchecked.size() - 1);
      solveCollisionsForItem(item, checked);
      checked.add(item);
    }
  }

  // Solve collisions between a specific item and other items.
  public void solveCollisionsForItem(MovableItem item, ArrayList<SynchronizedItem> targets) {
    int i = 0;
    while (!item.isDiscarded() && i < targets.size()) {
      SynchronizedItem target = targets.get(i++);
      if (!target.isDiscarded() && isOverlap(item, target)) {
        item.onCollisionWith(target);
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
