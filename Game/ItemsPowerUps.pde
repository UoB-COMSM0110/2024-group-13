// This file defines various power-ups on the game map.
// Power-ups are Synchronized items.

final String imagePathPowerUp = "data/PowerUp.png";
PImage imagePowerUp;
final String imagePathTrap = "data/Trap.png";
PImage imageTrap;
final String imagePathMagnet = "data/Magnet.png";
PImage imageMagnet;


void loadResoucesForPowerUps() {
  imagePowerUp = loadImage(imagePathPowerUp);
  imageTrap = loadImage(imagePathTrap);
  imageMagnet = loadImage(imagePathMagnet);
}


static final float defaultPowerUpDurationS = 5.0; 


final String itemTypePowerUp = "PowerUp";
int itemCountPowerUp;
final float powerUpRestoreTimeS = 10.0;

public abstract class PowerUp extends SynchronizedItem {
  public PowerUp() {
    super(itemTypePowerUp + itemCountPowerUp++, CHARACTER_SIZE, CHARACTER_SIZE);
  }

  public PowerUp replace() {
    discard().delete();
    page.addTimer(new OneOffTimer(powerUpRestoreTimeS, () -> {
          PowerUp newPowerUp = generateRandomPowerUp();
          newPowerUp.setX(getX()).setY(getY());
          page.addSyncItem(newPowerUp);
    }));
    return this;
  }

  @Override
  public PImage getImage() {
    return imagePowerUp;
  }
}


public class OpponentControlPowerUp extends PowerUp {
  public OpponentControlPowerUp() {
    super();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      Pacman pacman = (Pacman) item;
      int currentPlayerId = pacman.getPlayerId();
      int opponentId = (currentPlayerId == 1) ? 2 : 1;
      Pacman opponentPacman = (Pacman) page.getSyncItem(itemTypePacman + opponentId);

      if (opponentPacman != null) {
        takeControl(opponentPacman);
        Timer controlEndTimer = new OneOffTimer(defaultPowerUpDurationS,
            () -> releaseControl(opponentPacman));
        page.addTimer(controlEndTimer);
      }
      replace();
    }
  }

  @Override
  public PImage getImage() {
    return super.getImage();
  }

  private void takeControl(Pacman opponentPacman) {
    opponentPacman.setIsControlledByOpponent(true);
  }

  private void releaseControl(Pacman opponentPacman) {
    opponentPacman.setIsControlledByOpponent(false);
  }
}


public class TeleportPowerUp extends PowerUp {
  public TeleportPowerUp() {
    super();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      Pacman pacman = (Pacman) item;
      teleportPacman(pacman);
      replace();
    }
  }

  private void teleportPacman(Pacman pacman) {
    float newX = random(0, width); // This has problems.
    float newY = random(0, height); // This has problems.
    pacman.setX(newX);
    pacman.setY(newY);
  }

  @Override
  public PImage getImage() {
    return super.getImage();
  }
}


public class TimeFreezePowerUp extends PowerUp {
  public TimeFreezePowerUp() {
    super();
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
      replace();
    }
  }

  private void freezeOpponent(Pacman opponentPacman) {
    System.out.println("Freezing opponent Pacman.");
    opponentPacman.freeze();
    page.addTimer(new OneOffTimer(defaultPowerUpDurationS,
          () -> { unfreezeOpponent(opponentPacman); }));
  }

  private void unfreezeOpponent(Pacman opponentPacman) {
    System.out.println("Unfreezing opponent Pacman.");
    opponentPacman.unfreeze(); 
  }
}


public class SizeModificationPowerUp_Pacman extends PowerUp {
  public SizeModificationPowerUp_Pacman() {
    super();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      Pacman pacman = (Pacman) item;

      shrinkPacman(pacman);
      Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> resetPacmanSize(pacman));
      page.addTimer(changeEndTimer);
      replace();
    }
  }

  @Override
  public PImage getImage() {
    return super.getImage();
  }

  private void shrinkPacman(Pacman pacman) {
    pacman.zoom(0.5);
  }

  private void resetPacmanSize(Pacman pacman) {
    pacman.zoom(2.0);
  }
}


// if ghost could be stuck in the future version
public class SizeModificationPowerUp_Ghost extends PowerUp {
  public SizeModificationPowerUp_Ghost() {
    super();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      ArrayList<Ghost> ghosts = new ArrayList<Ghost>();
      for (SynchronizedItem syncItem : page.getSyncItems()) {
        if (syncItem instanceof Ghost) {
          ghosts.add((Ghost)syncItem);
        }
      }
      enlargeGhost(ghosts);
      Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> resetGhostSize(ghosts));
      page.addTimer(changeEndTimer);
      replace();
    }
  }

  @Override
  public PImage getImage() {
    return super.getImage();
  }

  private void enlargeGhost(ArrayList<Ghost> ghosts) {
    for (Ghost ghost : ghosts) {
      ghost.zoom(2.0);
    }
  }

  private void resetGhostSize(ArrayList<Ghost> ghosts) {
    for (Ghost ghost : ghosts) {
      ghost.zoom(0.5);
    }
  }
}


public class TrapPowerUp extends PowerUp {
  public TrapPowerUp() {
    super();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      Pacman pacman = (Pacman) item;
      Trap trap = new Trap(pacman.getPlayerId());
      trap.setX(this.getX()).setY(this.getY());
      page.addSyncItem(trap);
      replace();
    }
  }

  @Override
  public PImage getImage() {
    return super.getImage();
  }    
}


final String itemTypeTrap = "Trap";
int itemCountTrap;

public class Trap extends SynchronizedItem {
  private int owner;

  public Trap(int owner) {
    super(itemTypeTrap + itemCountTrap++, CHARACTER_SIZE * 1.5, CHARACTER_SIZE * 1.5);
    this.owner = owner;
  }

  @Override
  public JSONObject getStateJson() {
    JSONObject json = super.getStateJson();
    json.setInt("owner", getOwner());
    return json;
  }
  @Override
  public void setStateJson(JSONObject json) {
    super.setStateJson(json);
    this.owner = json.getInt("owner");
  }

  public int getOwner() {
    return this.owner;
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      Pacman pacman = (Pacman)item;
      if (pacman.getPlayerId() != this.owner) {
        reduceSpeed(pacman);
        Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> resetSpeed(pacman));
        page.addTimer(changeEndTimer);
      }
    }
    if (item instanceof Ghost) {
      Ghost ghost = (Ghost)item;
      reduceSpeed(ghost);
      Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> resetSpeed(ghost));
      page.addTimer(changeEndTimer);
    }
    delete();        
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
  public GhostMagnetPowerUp() {
    super();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      Magnet magnet = (Magnet)page.getSyncItem(itemTypeMagnet);
      if (magnet == null) {
        magnet = new Magnet();
        page.addSyncItem(magnet);
      }
      magnet.enableAt(this.getX(), this.getY());
      replace();
    }
  }

  @Override
  public PImage getImage() {
    return super.getImage();
  }      
}


final String itemTypeMagnet = "Magnet";

public class Magnet extends SynchronizedItem {
  public Magnet() {
    super(itemTypeMagnet, CHARACTER_SIZE, CHARACTER_SIZE);
  }

  public void enableAt(float x, float y) {
    setX(x).setY(y).restore();
    Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> { discard(); });
    page.addTimer(changeEndTimer); 
  }

  @Override
  public PImage getImage() {
    return imageMagnet;
  }  
}


public class SpeedSurgePowerUp extends PowerUp {
  public SpeedSurgePowerUp() {
    super();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      Pacman pacman = (Pacman) item;
      increaseSpeed(pacman);
      Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> resetSpeed(pacman));
      page.addTimer(changeEndTimer);        
      replace();
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


// ----------------------------------------------------------------

public PowerUp generateRandomPowerUp() {
  PowerUp powerUp = null;
  while (powerUp == null) {
    int number = (int)random(10.0); // [0.0, 10.0)
    switch (number) {
      case 0: { powerUp = new OpponentControlPowerUp(); break; }
      // case 1: { powerUp = new TeleportPowerUp(); break; }
      case 2: { powerUp = new TimeFreezePowerUp(); break; }
      case 3: { powerUp = new SizeModificationPowerUp_Pacman(); break; }
      case 4: { powerUp = new SizeModificationPowerUp_Ghost(); break; }
      case 5: { powerUp = new TrapPowerUp(); break; }
      case 6: { powerUp = new GhostMagnetPowerUp(); break; }
      default: { powerUp = new SpeedSurgePowerUp(); break; } // 1,7,8,9
    }
  }
  return powerUp;
}
