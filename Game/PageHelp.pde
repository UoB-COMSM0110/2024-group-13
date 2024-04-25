final String instructionSet1 = "data/Help1_objective.png";
final String instructionSet2 = "data/Help2_controls.png";
final String instructionSet3 = "data/Help3_powerup.png";
final String instructionSet4 = "data/Help4_shooting.png";
final String instructionSet5 = "data/Help5_winning.png";

final String instructionSet6 = "data/Help6_localmultiplayer.png";
final String instructionSet7 = "data/Help7_onlinemultiplayer.png";

// Objective Page of Instructions
public class HelpPage1 extends Page {
  private Page backPage;
  private PImage instructionImage;
  
  public HelpPage1(Page previousPage, Page backPage) {
    super("help1", previousPage);
    this.backPage = backPage;
    this.instructionImage = loadImage(instructionSet1);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(this.backPage); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Next page button 
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage2(this, this.backPage)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 40, 200, 720, 276);
  }

  @Override
  public void draw() {
    super.draw();
  }
}

// Controls Page of Instructions
public class HelpPage2 extends Page {
  private Page backPage;
  private PImage instructionImage;
  
  public HelpPage2(Page previousPage, Page backPage) {
    super("help2", previousPage);
    this.backPage = backPage;
    this.instructionImage = loadImage(instructionSet2);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(this.backPage); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Previous page button
    Button previousButton = new Button("PreviousButton", 200, 40, "Previous",
        () -> { trySwitchPage(getPreviousPage()); });
    previousButton.setX(55).setY(620);
    addLocalItem(previousButton);
    // Next page button
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage3(this, this.backPage)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 40, 200, 720, 276);
  }

  @Override
  public void draw() {
    super.draw();
  }
}

// Powerups and Hazards Page of Instructions
public class HelpPage3 extends Page {
  private Page backPage;
  private PImage instructionImage;
  
  public HelpPage3(Page previousPage, Page backPage) {
    super("help3", previousPage);
    this.backPage = backPage;
    this.instructionImage = loadImage(instructionSet3);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(this.backPage); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Previous page button
    Button previousButton = new Button("PreviousButton", 200, 40, "Previous",
        () -> { trySwitchPage(getPreviousPage()); });
    previousButton.setX(55).setY(620);
    addLocalItem(previousButton);
    // Next page button
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage4(this, this.backPage)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 40, 200, 720, 276);
  }

  @Override
  public void draw() {
    super.draw();
  }
}

// Shooting Mechanisms Page of Instructions
public class HelpPage4 extends Page {
  private Page backPage;
  private PImage instructionImage;
  
  public HelpPage4(Page previousPage, Page backPage) {
    super("help4", previousPage);
    this.backPage = backPage;
    this.instructionImage = loadImage(instructionSet4);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(this.backPage); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Previous page button
    Button previousButton = new Button("PreviousButton", 200, 40, "Previous",
        () -> { trySwitchPage(getPreviousPage()); });
    previousButton.setX(55).setY(620);
    addLocalItem(previousButton);
    // Next page button
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage5(this, this.backPage)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 40, 200, 720, 276);
  }

  @Override
  public void draw() {
    super.draw();
  }
}

// Winning the Game Page of Instructions
public class HelpPage5 extends Page {
  private Page backPage;
  private PImage instructionImage;
  
  public HelpPage5(Page previousPage, Page backPage) {
    super("help5", previousPage);
    this.backPage = backPage;
    this.instructionImage = loadImage(instructionSet5);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(this.backPage); });
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
    image(this.instructionImage, 40, 200, 720, 276);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
  }
}

// Local Multiplayer Instructions Page
public class HelpPage6 extends Page {
  private Page backPage;
  private PImage instructionImage;
  
  public HelpPage6(Page previousPage, Page backPage) {
    super("help6", previousPage);
    this.backPage = backPage;
    this.instructionImage = loadImage(instructionSet6);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(this.backPage); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
    // Next game mode page button
    Button nextButton = new Button("NextButton", 200, 40, "Next",
        () -> { trySwitchPage(new HelpPage7(this, this.backPage)); });
    nextButton.setX(545).setY(620);
    addLocalItem(nextButton);
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 40, 200, 720, 276);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
  }
}

// Online Multiplayer Instructions Page
public class HelpPage7 extends Page {
  private Page backPage;
  private PImage instructionImage;
  
  public HelpPage7(Page previousPage, Page backPage) {
    super("help7", previousPage);
    this.backPage = backPage;
    this.instructionImage = loadImage(instructionSet7);

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(this.backPage); });
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
    image(this.instructionImage, 40, 200, 720, 276);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
  }
}
