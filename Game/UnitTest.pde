import java.util.concurrent.TimeUnit;

public class Test {
  Pacman pacman_1;
  Pacman pacman_2;
  float init_size = CHARACTER_SIZE * 2.51;
  
  public Test() {
    gameInfo = new GameInfo();
    pacman_1 = new Pacman(1);
    pacman_2 = new Pacman(2);
    page = new PlayPage(null);
    page.addSyncItem(pacman_1);
    page.addSyncItem(pacman_2);
  }
  
  public void test() {
    testPowerUp();
    testCollisionSolving();
  }
  
  private void testPowerUp() {
    OpponentControlPowerUp opponentControl = new OpponentControlPowerUp();
    assert pacman_1.usingKeySetA() : "Pacman 1 should use KeySet A at first.";
    opponentControl.onCollisionWith(pacman_2);
    assert !pacman_1.usingKeySetA() : "Pacman 1 should not use KeySet A when opponent get Opponent Control PowerUp.";
    
    TimeFreezePowerUp frozen = new TimeFreezePowerUp();
    assert pacman_1.getFrozen() == 0 : "Pacman 1 should not be frozen at first.";
    frozen.onCollisionWith(pacman_2);
    assert pacman_1.getFrozen() != 0 : "Pacman 1 now should be frozen.";
    
    SizeModificationPowerUp_Pacman sizeModification = new SizeModificationPowerUp_Pacman();
    assert pacman_1.getH() == init_size && pacman_1.getW() == init_size : "The width and the height of Pacman_1 should be " + init_size + " .";
    sizeModification.onCollisionWith(pacman_1);
    assert pacman_1.getH() != init_size : "";
    
    TrapPowerUp trapPowerUp = new TrapPowerUp();
    assert pacman_1.getSpeed() == defaultPacmanSpeed : "Pacman_1's speed should be " + defaultPacmanSpeed + " at first.";
    trapPowerUp.onCollisionWith(pacman_2);

    Trap trap = (Trap) page.getSyncItem(itemTypeTrap + (itemCountTrap - 1));
    trap.onCollisionWith(pacman_1);
    assert pacman_1.getSpeed() < defaultPacmanSpeed : "Unlucky guy pacman_1 steps on the trap, so he slows down.";
    
    SpeedSurgePowerUp speedUp = new SpeedSurgePowerUp();
    assert pacman_2.getSpeed() == defaultPacmanSpeed : "Pacman_2's speed should be " + defaultPacmanSpeed + " at first.";
    speedUp.onCollisionWith(pacman_2);
    assert pacman_2.getSpeed() > defaultPacmanSpeed : "Pacman_2 get the speed surget power up, now he move really fast.";
  }

  private void testCollisionSolving() {
    int oldFrameCount = frameCount;
    frameCount++;
    gameInfo.update();
    gameInfo.updateEvolveTime();

    Ghost ghost = new Ghost();
    ghost.setX(0).setY(0);
    Coin coin = new Coin();
    coin.setX(0).setY(0);
    assert ghost.isOverlapWith(coin) : "Ghost and Coin should overlap.";
    ghost.tryStepbackFrom(coin); // This step back should not work.
    assert ghost.isOverlapWith(coin) : "Ghost and Coin should overlap.";
    ghost.tryPushbackFrom(coin, LEFTWARD);
    assert !ghost.isOverlapWith(coin) : "Ghost and Coin should not overlap.";
    assert ghost.getPenetrationDepthOf(coin, LEFTWARD) < 0.1 : "Ghost and Coin should be adjacent.";

    try {
      TimeUnit.MILLISECONDS.sleep(50);
    } catch (Exception e) {}
    frameCount++;
    gameInfo.update();

    ghost.setX(0).setY(0);
    ghost.setDirection(RIGHTWARD).setSpeed(100.0 / gameInfo.getLastEvolveIntervalS());
    ghost.move();
    coin.setLeftX(ghost.getRightX() - 1.0).setY(ghost.getY());
    assert ghost.isOverlapWith(coin) : "Ghost and Coin should overlap.";
    ghost.tryStepbackFrom(coin); // This step back should work.
    assert !ghost.isOverlapWith(coin) : "Ghost and Coin should not overlap.";
    assert ghost.getPenetrationDepthOf(coin) < 0.1 : "Ghost and Coin should be adjacent.";

    frameCount = oldFrameCount;
  }
}


void test() {
  new Test().test();
}
