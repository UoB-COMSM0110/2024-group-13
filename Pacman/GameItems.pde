
final static float SCALE = 10.0/300;

public class BreakableWall extends SynchronizedItem {
    public int strength;
    PImage image = loadImage("data/GUI/BigMudBrick.png");

    public BreakableWall(String name, float setX, float setY) {
        super(name, setX, setY);
        strength = 3;
        super.layer = 4;
        super.w = image.width * SCALE;
        super.h = image.height * SCALE;
    }

    public PImage getImage() {
        return image;
    }

}
