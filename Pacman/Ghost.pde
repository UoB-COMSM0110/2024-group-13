import java.util.Random;

final String itemTypeGhost = "Ghost";
String ghostImagePath = "data/ghost.jpg";
PImage ghostImage;


// Ghost class
public class Ghost extends MovableItem {
    private Random random = new Random();
    private int ghostLife;
    
    // Constructor
    public Ghost(String name, float w, float h) {
        super(name, w, h);
        ghostLife = 3;
        setSpeed(30.0); // set Ghost speed
        randomizeDirection(); // Start by a random direction
    }

    @Override
    public void evolve(GameInfo gInfo) {
        //  Randomly change direction
        if (random.nextInt(35) == 0) {
            // probability of changing direction on each call
            randomizeDirection();
        }
        
        // keep moving
        super.evolve(gInfo);
    }
    
    private void randomizeDirection() {
        int[] directions = {UPWARD, RIGHTWARD, DOWNWARD, LEFTWARD};
        setDirection(directions[random.nextInt(directions.length)]);
    }
    
    public void move(GameInfo gInfo) {
        if (!getMoving()) {
            startMoving(); // 
        }
        super.move(gInfo); // update location
    }

    @Override
    public PImage getImage() {
        // return loadImage("ghost.png");
        if (ghostImage == null){
        ghostImage = loadImage(ghostImagePath);
        }
        return ghostImage;
    }
}
