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
    assert pacman_1.getSpeed() == 100 : "Pacman_1's speed should be 100 at first.";
    trapPowerUp.onCollisionWith(pacman_2);

    Trap trap = (Trap) page.getSyncItem(itemTypeTrap + (itemCountTrap - 1));
    trap.onCollisionWith(pacman_1);
    assert pacman_1.getSpeed() < 100 : "Unlucky guy pacman_1 steps on the trap, so he slows down.";
    
    SpeedSurgePowerUp speedUp = new SpeedSurgePowerUp();
    assert pacman_2.getSpeed() == 100 : "Pacman_2's speed should be 100 at first.";
    speedUp.onCollisionWith(pacman_2);
    assert pacman_2.getSpeed() > 100 : "Pacman_2 get the speed surget power up, now he move really fast.";
  }
  
}
