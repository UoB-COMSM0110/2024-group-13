// This file defines various power-ups on the game map.
// Power-ups are Synchronized items.

final String imagePathPowerUp = "data/PowerUp.png";
PImage imagePowerUp;
final String imagePathTrap = "data/Trap.png";
PImage imageTrap;
final String imagePathMagnet = "data/magnet.png";
PImage imageMagnet;


void loadResoucesForPowerUps() {
  imagePowerUp = loadImage(imagePathPowerUp);
  imageTrap = loadImage(imagePathTrap);
  imageMagnet = loadImage(imagePathMagnet);
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

public class TeleportPowerUp extends PowerUp {

    public TeleportPowerUp(float w, float h) {
      super(w, h);
    }

    @Override
    public void onCollisionWith(SynchronizedItem item) {
        if (item instanceof Pacman) {
            Pacman pacman = (Pacman) item;
            teleportPacman(pacman);
            discard();
        }
    }

    private void teleportPacman(Pacman pacman) {
        float newX = random(0, width); 
        float newY = random(0, height);
        pacman.setX(newX);
        pacman.setY(newY);
    }

    @Override
    public PImage getImage() {
      return super.getImage();
    }
}

public class TimeFreezePowerUp extends PowerUp {
    private int freezeDuration = 300; 

    public TimeFreezePowerUp(float w, float h) {
        super(w, h);
    }
    
    @Override
    public void onCollisionWith(SynchronizedItem item) {
        if (item instanceof Pacman) {
            Pacman pacman = (Pacman) item;
            int currentPlayerId = pacman.getPlayerId();
            int opponentId = (currentPlayerId == 1) ? 2 : 1;
            Pacman opponentPacman = (Pacman) page.getSyncItem(itemTypePacman + opponentId);

            if (opponentPacman != null) {
                freezeOpponent(opponentPacman);
            }
            discard();
        }
    }

    private void freezeOpponent(Pacman opponentPacman) {
        System.out.println("Freezing opponent Pacman.");
        opponentPacman.freeze();
        
        int delayMillis = (int)(freezeDuration / 60.0 * 1000);
        new java.util.Timer().schedule(new java.util.TimerTask() {
            @Override
            public void run() {
                unfreezeOpponent(opponentPacman);
            }
        }, delayMillis);
    }
    
    private void unfreezeOpponent(Pacman opponentPacman) {
        System.out.println("Unfreezing opponent Pacman.");
        opponentPacman.unfreeze(); 
    }
}

public class SizeModificationPowerUp_Pacman extends PowerUp {
  
    private int duration = 5;
  
    public SizeModificationPowerUp_Pacman(float w, float h) {
        super(w, h);
    }
    
    @Override
    public void onCollisionWith(SynchronizedItem item) {
      if (item instanceof Pacman) {
        Pacman pacman = (Pacman) item;

        shrinkPacman(pacman);
        Timer changeEndTimer = new OneOffTimer(duration, () -> resetPacmanSize(pacman));
        page.addTimer(changeEndTimer);
        discard();
      }
    }
    
    @Override
    public PImage getImage() {
      return super.getImage();
    }
    
    private void shrinkPacman(Pacman pacman) {
      pacman.setW(pacman.getW() * 0.5);
      pacman.setH(pacman.getH() * 0.5);
    }
    
    private void resetPacmanSize(Pacman pacman) {
      pacman.setW(pacman.getW() * 2);
      pacman.setH(pacman.getH() * 2);
    }
}

// if ghost could be stuck in the future version
public class SizeModificationPowerUp_Ghost extends PowerUp {
  
    private int duration = 5;
  
    public SizeModificationPowerUp_Ghost(float w, float h) {
        super(w, h);
    }
    
    @Override
    public void onCollisionWith(SynchronizedItem item) {
      if (item instanceof Pacman) {
        ArrayList<SynchronizedItem> ghosts = page.getSyncItemsByNameAndCount(itemTypeGhost, itemCountGhost);
        if (ghosts != null) {
          enlargeGhost(ghosts);
          Timer changeEndTimer = new OneOffTimer(duration, () -> resetGhostSize(ghosts));
          page.addTimer(changeEndTimer);
          discard();
        }
      }
    }
    
    @Override
    public PImage getImage() {
      return super.getImage();
    }
    
    private void enlargeGhost(ArrayList<SynchronizedItem> ghosts) {
      for (SynchronizedItem ghost : ghosts) {
        if (ghost != null) {
          ghost.setW(ghost.getW() * 2);
          ghost.setH(ghost.getH() * 2);
        }
      }
    }
    
    private void resetGhostSize(ArrayList<SynchronizedItem> ghosts) {
      for (SynchronizedItem ghost : ghosts) {
        if (ghost != null) {
          ghost.setW(ghost.getW() * 0.5);
          ghost.setH(ghost.getH() * 0.5);
        }
      }
    }
}

public class TrapPowerUp extends PowerUp {
  
    public TrapPowerUp(float w, float h) {
        super(w, h);
    }
    
    @Override
    public void onCollisionWith(SynchronizedItem item) {
      if (item instanceof Pacman) {
        Pacman pacman = (Pacman) item;
        Trap trap = new Trap(CHARACTER_SIZE * 1.5, CHARACTER_SIZE * 1.5);
        trap.setX(this.getX()).setY(this.getY());
        trap.setOwner(pacman.getPlayerId());
        page.addSyncItem(trap);
        discard();
      }
    }
    
    @Override
    public PImage getImage() {
      return super.getImage();
    }    
}

public class Trap extends TrapPowerUp {
    
    private int owner;
    private int duration = 5;
    
    public Trap(float w, float h) {
        super(w, h);
    }
    
    public void setOwner(int playerId) {
        this.owner = playerId;
    }
    
    public int getOwner() {
        return this.owner;
    }
    
    @Override
    public void onCollisionWith(SynchronizedItem item) {
      if (item instanceof Pacman) {
        Pacman pacman = (Pacman) item;
        if (pacman.getPlayerId() != this.owner) {
          reduceSpeed(pacman);
          Timer changeEndTimer = new OneOffTimer(duration, () -> resetSpeed(pacman));
          page.addTimer(changeEndTimer);
          discard();
        }
      }
      if (item instanceof Ghost) {
        Ghost ghost = (Ghost) item;
        reduceSpeed(ghost);
        Timer changeEndTimer = new OneOffTimer(duration, () -> resetSpeed(ghost));
        page.addTimer(changeEndTimer);
        discard();        
      }
    }
    
    @Override
    public PImage getImage() {
      return imageTrap;
    }    
    
    private void reduceSpeed(MovableItem item) {
      item.setSpeed(item.getSpeed() * 0.5);
    }
    
    private void resetSpeed(MovableItem item) {
      item.setSpeed(item.getSpeed() * 2);
    }    
}

public class GhostMagnetPowerUp extends PowerUp {
    
    public GhostMagnetPowerUp(float w, float h) {
        super(w, h);
    }
    
    @Override
    public void onCollisionWith(SynchronizedItem item) {
      if (item instanceof Pacman) {
        Magnet magnet = new Magnet(CHARACTER_SIZE, CHARACTER_SIZE);
        magnet.setX(this.getX()).setY(this.getY());
        page.addSyncItem(magnet);
        discard();
      }
    }
    
    @Override
    public PImage getImage() {
      return super.getImage();
    }      
}

final String itemTypeMagnet = "Magnet";
int itemCountMagnet;

public class Magnet extends SynchronizedItem {
    
    private int duration = 5;
    
    public Magnet(float w, float h) {
      super(itemTypeMagnet + itemCountMagnet++, w, h);
      Timer changeEndTimer = new OneOffTimer(duration, () -> this.discard());
      page.addTimer(changeEndTimer); 
    }
    
    //@Override
    //public void onCollisionWith(SynchronizedItem item) {
    //  if (item instanceof Pacman) {
    //    gameInfo.activateGhostMagnet(this.getX(), this.getY());
    //    Timer changeEndTimer = new OneOffTimer(duration, () -> gameInfo.deactivateGhostMagnet());
    //    page.addTimer(changeEndTimer);        
    //    discard();
    //  }
    //}
    
    @Override
    public PImage getImage() {
      return imageMagnet;
    }  
    
}

public class SpeedSurgePowerUp extends PowerUp {
    
    private int duration = 5;
    
    public SpeedSurgePowerUp(float w, float h) {
        super(w, h);
    }
    
    @Override
    public void onCollisionWith(SynchronizedItem item) {
      if (item instanceof Pacman) {
        Pacman pacman = (Pacman) item;
        increaseSpeed(pacman);
        Timer changeEndTimer = new OneOffTimer(duration, () -> resetSpeed(pacman));
        page.addTimer(changeEndTimer);        
        discard();
      }
    }
    
    @Override
    public PImage getImage() {
      return super.getImage();
    }
    
    private void increaseSpeed(MovableItem item) {
      item.setSpeed(item.getSpeed() * 2.0);
    }
    
    private void resetSpeed(MovableItem item) {
      item.setSpeed(item.getSpeed() * 0.5);
    }
}
