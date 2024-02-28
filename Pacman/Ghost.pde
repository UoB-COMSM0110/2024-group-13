String ghostImagePath = "Item/ghost.jpg";
PImage ghostImage;
import java.util.Random;

// Ghost class
public class Ghost extends MovableItem {
    private Random random = new Random();
    // Constructor
    public Ghost(String name, float x, float y) {
        super(name, x, y);
        setSpeed(1.0); // set Ghost speed
        randomizeDirection(); // Start by a random direction
    }

    @Override
    public void evolve(GameInfo gInfo) {
        // check moveable
        if (getMoving()) {
            move();
        }
        // Randomly change direction
        if (random.nextInt(10) == 0) { 
        // 0.1 probability of changing direction on each call
            randomizeDirection(); 
        }
    }

    private void randomizeDirection() {
        int[] directions = {UPWARD, RIGHTWARD, DOWNWARD, LEFTWARD};
        setDirection(directions[random.nextInt(directions.length)]);
        startMoving(); // Start moving after setting direction
    }

    @Override
    public PImage getImage() {
        // return loadImage("ghost.png");
        return ghostImage;
    }
}
