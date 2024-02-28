
final static float SCALE = 10.0/700;

public class BreakableWall extends SynchronizedItem {
    public int strength;
    PImage image = loadImage("data/GUI/BreakableBrick.png");

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

public class IndestructableWall extends LocalItem {
    PImage image = loadImage("data/GUI/IndestructableBrick.png");

    public IndestructableWall(String name, float setX, float setY) {
        super(name, setX, setY);
        super.layer = 4;
        super.w = image.width * SCALE;
        super.h = image.height * SCALE;
    }

    public PImage getImage() {
        return image;
    }

}

public class Coin extends SynchronizedItem {
    PImage image = loadImage("data/GUI/Coin.png");

    public Coin(String name, float setX, float setY) {
        super(name, setX, setY);
        super.layer = 1;
        super.w = image.width * SCALE;
        super.h = image.height * SCALE;
    }

    public PImage getImage() {
        return image;
    }

}

public class PowerUp extends SynchronizedItem {
    PImage image = loadImage("data/GUI/PowerUp.png");

    public PowerUp(String name, float setX, float setY) {
        super(name, setX, setY);
        super.layer = 1;
        super.w = image.width * SCALE;
        super.h = image.height * SCALE;
    }

    public PImage getImage() {
        return image;
    }

}