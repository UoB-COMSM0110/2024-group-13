# Code Style

We apply the code style used in Java lecture.

```
public class Character {
  private static int numberOfCharacters;

  private int healthPoints;
  private int magicPoints;

  public void attackEnemy(Character enemy) {
    if (isWithinRange(enemy)) {
      dealDamageTo(enemy);
    }
  }
}
```

