// This file defines various power-ups on the game map.
// Power-ups are Synchronized items.

final String imagePathPowerUp = "data/PowerUp.png";
PImage imagePowerUp;


void loadResoucesForPowerUps() {
  imagePowerUp = loadImage(imagePathPowerUp);
}


final String itemTypePowerUp = "PowerUp";
int itemCountPowerUp;

public class PowerUp extends SynchronizedItem {
  
  private boolean inUse = false;
  
  public PowerUp(float w, float h) {
    super(itemTypePowerUp + itemCountPowerUp++, w, h);
  }
  
  public boolean getInUse() {
    return this.inUse;
  }
  
  public PowerUp setInUse(boolean status) {
    this.inUse = status;
    return this;
  }
  

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if(item instanceof Pacman){
      discard();
    }
  }  

  @Override
  public PImage getImage() {
    return imagePowerUp;
  }
}


public class OpponentControlPowerUp extends PowerUp {
    private int duration = 5; 


    public OpponentControlPowerUp(float w, float h) {
      super(w, h);
    }


    @Override
    public void onCollisionWith(SynchronizedItem item) {
      if (item instanceof Pacman) {
        Pacman pacman = (Pacman) item;
        int currentPlayerId = pacman.getPlayerId();
        int opponentId = (currentPlayerId == 1) ? 2 : 1;
        // Pacman opponentPacman = findPacmanById(opponentId);
        Pacman opponentPacman = (Pacman) page.getSyncItem(itemTypePacman + opponentId);
          
        if (opponentPacman != null) {
          takeControl(opponentPacman);
          Timer controlEndTimer = new OneOffTimer(duration, () -> releaseControl(opponentPacman));
          page.addTimer(controlEndTimer);
        }
        discard();
      }
    }
    
    @Override
    public PImage getImage() {
      return super.getImage();
    }

    //private Pacman findPacmanById(int id) {
    //  ArrayList<SynchronizedItem> syncItems= page.getSyncItems();
    //  for (SynchronizedItem item : syncItems) {
    //    if (item instanceof Pacman) {
    //      Pacman pacman = (Pacman) item;
    //      if (pacman.getPlayerId() == id) {
    //        return pacman;
    //      }
    //    }
    //  }
    //  return null; 
    //}

    private void takeControl(Pacman opponentPacman) {
      opponentPacman.setIsControlledByOpponent(true);
    }

    private void releaseControl(Pacman opponentPacman) {
      opponentPacman.setIsControlledByOpponent(false);
      this.setInUse(false);
    }

}
