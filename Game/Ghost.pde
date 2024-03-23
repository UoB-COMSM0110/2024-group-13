import java.util.Random;

final String imagePathGhost = "data/Ghost.jpg";
PImage imageGhost;

void loadResoucesForFigures() {
  imageGhost = loadImage(imagePathGhost);
}


final String itemTypeGhost = "Ghost";
int itemCountGhost;

// Ghost class
public class Ghost extends MovableItem {
    private Random random = new Random();
    private int healthPoints;
    
    // Constructor
    public Ghost(float w, float h) {
        super(itemTypeGhost + itemCountGhost++, w, h);
        this.healthPoints = 3;
        setSpeed(30.0); // set Ghost speed
        randomizeDirection(); // Start by a random direction
    }
    
    public int getGhostLife() {
      return healthPoints;
    }
    
    public Ghost setGhostLife(int healthPoints) {
      this.healthPoints = healthPoints;
      return this;
    }
    
    @Override
    public void evolve(GameInfo gInfo, Page page) {
        //  Randomly change direction
        if (random.nextInt(35) == 0) {
            // probability of changing direction on each call
            randomizeDirection();
        }
        // keep moving
        super.evolve(gInfo, page);
    }
    
    private void randomizeDirection() {
        int[] directions = {UPWARD, RIGHTWARD, DOWNWARD, LEFTWARD};
        setDirection(directions[random.nextInt(directions.length)]);
    }

    @Override
    public PImage getImage() {
        return imageGhost;
    }
}
