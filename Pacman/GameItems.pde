
final static float SCALE = 10.0/128;

public class BreakableWall extends Item {
    public int strength;
    PImage image = loadImage("data/GUI/BigMudBrick.png");

    public BreakableWall(float setX, float setY) {
      super("breakableWall", setX, setY);
        strength = 3;
        super.layer = 4;
        super.w = image.width * SCALE;
        super.h = image.height * SCALE;
    }

    public PImage getImage() {
        return image;
    }

}
