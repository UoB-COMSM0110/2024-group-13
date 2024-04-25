class Test {
  GameInfo gameInfo;
  Pacman pacman;
  float init_size;
  
  Test() {
    gameInfo = new GameInfo();
    pacman = new Pacman(1);
    init_size = 2.51 * CHARACTER_SIZE;
  }
  
  void test() {
    
  }
  
  void testPowerUp() {
    OpponentControlPowerUp opponentControl = new OpponentControlPowerUp();
    opponentControl.setX(20).setY(20);
    assert pacman.usingKeySetA() : "Test player 1 should use keyset A.";
    // onCollisionWith powerup
    pacman.setX(20).setY(20);
    assert !pacman.usingKeySetA() : "Pacman now should not use keyset A.";
    
    SizeModificationPowerUp_Pacman sizeModify = new SizeModificationPowerUp_Pacman();
    assert pacman.getH() == init_size && pacman.getW() == init_size : "Pacman's width and height should be " + init_size + " at first.";
    sizeModify.setX(20).setY(20);
    assert pacman.getH() != init_size && pacman.getW() != init_size : "Pacman's width and height should smaller than " + init_size + ".";
    
    Pacman toBeSlowDown = new Pacman(2);
    TrapPowerUp trapPowerUp = new TrapPowerUp();
    pacman.setX(50).setY(50);
    trapPowerUp.setX(50).setY(50);
    pacman.setX(20).setY(20);
    // Unlucky guy come out
    assert toBeSlowDown.getSpeed() == 100 : "Pacman's speed should be 100 at first.";
    toBeSlowDown.setX(50).setY(50);
    assert toBeSlowDown.getSpeed() != 100 : "Now Pacman's speed should not be 100 as he is unlucky.";
  }
}
