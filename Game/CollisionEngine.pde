// Class for detecting and solving collisions between items.
public class CollisionEngine {
  public void solveCollisions() {
    solveCollisions(() -> false);
  }
  public void solveCollisions(Condition stopCond) {
    (new SimpleCollisionEngine()).solveCollisions(stopCond);
  }
}


// Post-collision detection.
// No passing-through detection.
// No collision order calculation.
// No multiple-object collision.
public class SimpleCollisionEngine {
  // Solve all collisions between items.
  public void solveCollisions(Condition stopCond) {
    ArrayList<SynchronizedItem> checked = new ArrayList<SynchronizedItem>();
    ArrayList<MovableItem> unchecked = new ArrayList<MovableItem>();
    for (SynchronizedItem item : page.getSyncItems()) {
      if (item instanceof MovableItem) {
        unchecked.add((MovableItem)item);
      } else {
        checked.add(item);
      }
    }
    while (!stopCond.eval() && unchecked.size() > 0) {
      MovableItem item = unchecked.remove(unchecked.size() - 1);
      solveCollisionsForItem(item, checked, stopCond);
      checked.add(item);
    }
  }

  // Solve collisions between a specific item and other items.
  public void solveCollisionsForItem(MovableItem item,
      ArrayList<SynchronizedItem> targets, Condition stopCond) {
    int i = 0;
    while (!stopCond.eval() && i < targets.size()) {
      SynchronizedItem target = targets.get(i++);
      if (isOverlap(item, target)) {
        if (!target.isDiscarded() && !item.noCollisionCheck()) {
          item.onCollisionWith(target);
        }
        if (!item.isDiscarded() && !target.noCollisionCheck()) {
          target.onCollisionWith(item);
        }
      }
    }
  }

  // Currently only works for rectangular items.
  public boolean isOverlap(SynchronizedItem item, SynchronizedItem target) {
    return item.isOverlapWith(target);
  }
}
