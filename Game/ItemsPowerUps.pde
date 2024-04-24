// This file defines various power-ups on the game map.
// Power-ups are Synchronized items.

final String imagePathPowerUp = "data/PowerUp.png";
PImage imagePowerUp;
final String imagePathTrap = "data/Trap.png";
PImage imageTrap;
final String imagePathMagnet = "data/Magnet.png";
PImage imageMagnet;


void loadResourcesForPowerUps() {
  imagePowerUp = loadImage(imagePathPowerUp);
  imageTrap = loadImage(imagePathTrap);
  imageMagnet = loadImage(imagePathMagnet);
}


static final float defaultPowerUpDurationS = 5.0; 
int nextBuffId = 1;
private int getNextBuffId() { return nextBuffId++; }

private void removeBuffDesc(int buffId, Pacman pacman) {
  String buffIdStr = String.valueOf(buffId);
  String desc = pacman.getBuffDesc();
  if (desc.length() <= buffIdStr.length()) { return; }
  if (!desc.startsWith(buffIdStr)) { return; }
  char type = desc.charAt(buffIdStr.length());
  if (type != '+' && type != '-') { return; }
  pacman.setBuffDesc("");
}


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
      Pacman pacman = (Pacman)item;
      Pacman opponentPacman = pacman.getOpponent();
      if (opponentPacman != null) {
        int buffId = getNextBuffId();
        opponentPacman.setControlledByOpponent(buffId);
        pacman.setBuffDesc(buffId + "+Control rival");
        opponentPacman.setBuffDesc(buffId + "-Loose control");

        Timer controlEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> {
            if (opponentPacman.getControlledByOpponent() == buffId) {
              opponentPacman.setControlledByOpponent(0);
            }
            removeBuffDesc(buffId, pacman);
            removeBuffDesc(buffId, opponentPacman);
        });
        page.addTimer(controlEndTimer);
      }
      replace();
    }
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
}


public class TimeFreezePowerUp extends PowerUp {
  public TimeFreezePowerUp() {
    super();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      Pacman pacman = (Pacman)item;
      Pacman opponentPacman = pacman.getOpponent();
      if (opponentPacman != null) {
        int buffId = getNextBuffId();
        opponentPacman.setFrozen(buffId);
        opponentPacman.setBuffDesc(buffId + "-Frozen");

        page.addTimer(new OneOffTimer(defaultPowerUpDurationS, () -> {
            if (opponentPacman.getFrozen() == buffId) {
              opponentPacman.setFrozen(0); 
            }
            removeBuffDesc(buffId, opponentPacman);
        }));
      }
      replace();
    }
  }
}


public class SizeModificationPowerUp_Pacman extends PowerUp {
  public SizeModificationPowerUp_Pacman() {
    super();
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      int buffId = getNextBuffId();
      Pacman pacman = (Pacman)item;
      pacman.zoom(0.5);
      pacman.setBuffDesc(buffId + "+Shrunk");

      Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> {
          pacman.zoom(2.0);
          removeBuffDesc(buffId, pacman);
      });
      page.addTimer(changeEndTimer);
      replace();
    }
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
      trap.setGenerator(this).setX(this.getX()).setY(this.getY());
      page.addSyncItem(trap);
      page.addTimer(new OneOffTimer(20.0, () -> { trap.discard().delete(); }));
      discard();
    }
  }
}


final String itemTypeTrap = "Trap";
int itemCountTrap;

public class Trap extends SynchronizedItem {
  private int owner;
  private TrapPowerUp generator;

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

  public Trap setGenerator(TrapPowerUp generator) {
    this.generator = generator;
    return this;
  }

  public int getOwner() {
    return this.owner;
  }

  @Override
  void delete() {
    super.delete();
    if (this.generator != null) {
      this.generator.replace();
      this.generator = null;
    }
  }

  @Override
  public void onCollisionWith(SynchronizedItem item) {
    if (item instanceof Pacman) {
      Pacman pacman = (Pacman)item;
      if (pacman.getPlayerId() != this.owner) {
        int buffId = getNextBuffId();
        pacman.setSpeed(pacman.getSpeed() * 0.5);
        pacman.setBuffDesc(buffId + "-Slowed down");

        Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> {
            pacman.setSpeed(pacman.getSpeed() * 2.0);
            removeBuffDesc(buffId, pacman);
        });
        page.addTimer(changeEndTimer);
        discard().delete();        
      }
    }
    if (item instanceof Ghost) {
      Ghost ghost = (Ghost)item;
      ghost.setSpeed(ghost.getSpeed() * 0.5);
      Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> {
          ghost.setSpeed(ghost.getSpeed() * 2.0);
      });
      page.addTimer(changeEndTimer);
      discard().delete();        
    }
  }

  @Override
  public PImage getImage() {
    return imageTrap;
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
      Pacman pacman = (Pacman)item;
      int buffId = getNextBuffId();
      pacman.setSpeed(pacman.getSpeed() * 2.0);
      pacman.setBuffDesc(buffId + "+Speed surge");

      Timer changeEndTimer = new OneOffTimer(defaultPowerUpDurationS, () -> {
          pacman.setSpeed(pacman.getSpeed() * 0.5);
          removeBuffDesc(buffId, pacman);
      });
      page.addTimer(changeEndTimer);        
      replace();
    }
  }
}


// ----------------------------------------------------------------

public PowerUp generateRandomPowerUp() {
  PowerUp powerUp = null;
  while (powerUp == null) {
    int number = (int)random(9.0); // [0.0, 9.0)
    switch (number) {
      // TeleportPowerUp not used
      case 0: { powerUp = new OpponentControlPowerUp(); break; }
      case 1: { powerUp = new TimeFreezePowerUp(); break; }
      case 2: { powerUp = new SizeModificationPowerUp_Pacman(); break; }
      case 3: { powerUp = new SizeModificationPowerUp_Ghost(); break; }
      case 4: { powerUp = new TrapPowerUp(); break; }
      case 5: { powerUp = new GhostMagnetPowerUp(); break; }
      default: { powerUp = new SpeedSurgePowerUp(); break; }
    }
  }
  return powerUp;
}
