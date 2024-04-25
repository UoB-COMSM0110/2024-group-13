final String imagePathInstructionSet = "data/objectiveImage1.png";
final String instructionSet1 = "data/objectiveImage1.png";
final String instructionSet2 = "data/controlsImage2.png";
final String instructionSet3 = "data/powerupImage3.png";
final String instructionSet4 = "data/shootingImage4.png";
final String instructionSet5 = "data/winningImage5.png";

final String instructionSet6 = "data/localmultiplayer.png";
final String instructionSet7 = "data/onlinemultiplayer.png";

// Objective Page of Instructions
public class HelpPage1 extends Page {
  private PImage instructionImage;
  
  public HelpPage1(Page previousPage) {
    super("help1", previousPage);
    this.instructionImage = loadImage(instructionSet1);

    // Back to Home Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Home",
        () -> { trySwitchPage(getPreviousPage()); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Next page button 
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage2(this)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
  }
}

// Controls Page of Instructions
public class HelpPage2 extends Page {
  private PImage instructionImage;
  
  public HelpPage2(Page previousPage) {
    super("help2", previousPage);
    this.instructionImage = loadImage(instructionSet2);

    // Back to Home Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Home",
        () -> { trySwitchPage(new StartPage(null)); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Previous page button
    Button previousButton = new Button("PreviousButton", 200, 40, "Previous",
        () -> { trySwitchPage(getPreviousPage()); });
    previousButton.setX(55).setY(620);
    addLocalItem(previousButton);
    // Next page button
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage3(this)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
  }
}

// Powerups and Hazards Page of Instructions
public class HelpPage3 extends Page {
  private PImage instructionImage;
  
  public HelpPage3(Page previousPage) {
    super("help3", previousPage);
    this.instructionImage = loadImage(instructionSet3);

    // Back to Home Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Home",
        () -> { trySwitchPage(new StartPage(null)); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Previous page button
    Button previousButton = new Button("PreviousButton", 200, 40, "Previous",
        () -> { trySwitchPage(getPreviousPage()); });
    previousButton.setX(55).setY(620);
    addLocalItem(previousButton);
    // Next page button
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage4(this)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
  }
}

// Shooting Mechanisms Page of Instructions
public class HelpPage4 extends Page {
  private PImage instructionImage;
  
  public HelpPage4(Page previousPage) {
    super("help4", previousPage);
    this.instructionImage = loadImage(instructionSet4);

    // Back to Home Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Home",
        () -> { trySwitchPage(new StartPage(null)); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Previous page button
    Button previousButton = new Button("PreviousButton", 200, 40, "Previous",
        () -> { trySwitchPage(getPreviousPage()); });
    previousButton.setX(55).setY(620);
    addLocalItem(previousButton);
    // Next page button
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage5(this)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
  }
}

// Winning the Game Page of Instructions
public class HelpPage5 extends Page {
  private PImage instructionImage;
  
  public HelpPage5(Page previousPage) {
    super("help5", previousPage);
    this.instructionImage = loadImage(instructionSet5);

    // Back to Home Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Home",
        () -> { trySwitchPage(new StartPage(null)); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Previous page button
    Button previousButton = new Button("PreviousButton", 200, 40, "Previous",
        () -> { trySwitchPage(getPreviousPage()); });
    previousButton.setX(55).setY(620);
    addLocalItem(previousButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
  }
}

// Local Multiplayer Instructions Page
public class HelpPage6 extends Page {
  private PImage instructionImage;
  
  public HelpPage6(Page previousPage) {
    super("help6", previousPage);
    this.instructionImage = loadImage(instructionSet6);

    // Back to Home Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Home",
        () -> { trySwitchPage(getPreviousPage()); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Next game mode page button
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage7(this)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
  }
}

// Online Multiplayer Instructions Page
public class HelpPage7 extends Page {
  private PImage instructionImage;
  
  public HelpPage7(Page previousPage) {
    super("help7", previousPage);
    this.instructionImage = loadImage(instructionSet7);

    // Back to Home Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Home",
        () -> { trySwitchPage(new StartPage(null)); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Previous page button
    Button previousButton = new Button("PreviousButton", 200, 40, "Previous",
        () -> { trySwitchPage(getPreviousPage()); });
    previousButton.setX(55).setY(620);
    addLocalItem(previousButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
  }
}
