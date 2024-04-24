final String imagePathHelpPageOverlay = "data/HelpPageOverlay.png";
final String instructionSet1 = "data/objectiveImage1.png";
final String instructionSet2 = "data/controlsImage2.png";
final String instructionSet3 = "data/powerupImage3.png";
final String instructionSet4 = "data/shootingImage4.png";
final String instructionSet5 = "data/winningImage5.png";
final String instructionSet6 = "data/objectiveImage1.png";
final String instructionSet7 = "data/controlsImage2.png";

// Objective Page of Instructions
public class HelpPage1 extends Page {
  private PImage imageOverlay;
  private PImage instructionImage;
  
  public HelpPage1(Page previousPage) {
    super("help1", previousPage);
    this.imageOverlay = loadImage(imagePathHelpPageOverlay);
    this.instructionImage = loadImage(instructionSet1);

    // Back to Start Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Back",
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
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) { return false; }
    if (gameInfo.isClientHost() && json.getString("page").equals("start")
        && json.getString("nextPage").equals("play")) {
      trySwitchPage(new PlayPage(getPreviousPage()));
    }
    return true;
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageOverlay, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
    text("Objective", 300, 110);
  }
}

// Controls Page of Instructions
public class HelpPage2 extends Page {
  private PImage imageOverlay;
  private PImage instructionImage;
  
  public HelpPage2(Page previousPage) {
    super("help2", previousPage);
    this.imageOverlay = loadImage(imagePathHelpPageOverlay);
    this.instructionImage = loadImage(instructionSet2);

    // Back to Start Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Back",
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
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) { return false; }
    if (gameInfo.isClientHost() && json.getString("page").equals("start")
        && json.getString("nextPage").equals("play")) {
      trySwitchPage(new PlayPage(getPreviousPage()));
    }
    return true;
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageOverlay, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
    text("Controls", 300, 110);
  }
}

// Powerups and Hazards Page of Instructions
public class HelpPage3 extends Page {
  private PImage imageOverlay;
  private PImage instructionImage;
  
  public HelpPage3(Page previousPage) {
    super("help3", previousPage);
    this.imageOverlay = loadImage(imagePathHelpPageOverlay);
    this.instructionImage = loadImage(instructionSet3);

    // Back to Start Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Back",
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
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) { return false; }
    if (gameInfo.isClientHost() && json.getString("page").equals("start")
        && json.getString("nextPage").equals("play")) {
      trySwitchPage(new PlayPage(getPreviousPage()));
    }
    return true;
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageOverlay, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
    text("Powerups and Hazards", 300, 110);
  }
}

// Shooting Mechanisms Page of Instructions
public class HelpPage4 extends Page {
  private PImage imageOverlay;
  private PImage instructionImage;
  
  public HelpPage4(Page previousPage) {
    super("help4", previousPage);
    this.imageOverlay = loadImage(imagePathHelpPageOverlay);
    this.instructionImage = loadImage(instructionSet4);

    // Back to Start Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Back",
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
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) { return false; }
    if (gameInfo.isClientHost() && json.getString("page").equals("start")
        && json.getString("nextPage").equals("play")) {
      trySwitchPage(new PlayPage(getPreviousPage()));
    }
    return true;
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageOverlay, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
    text("Shooting Mechanisms", 300, 110);
  }
}

// Winning the Game Page of Instructions
public class HelpPage5 extends Page {
  private PImage imageOverlay;
  private PImage instructionImage;
  
  public HelpPage5(Page previousPage) {
    super("help5", previousPage);
    this.imageOverlay = loadImage(imagePathHelpPageOverlay);
    this.instructionImage = loadImage(instructionSet5);

    // Back to Start Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Back",
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
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) { return false; }
    if (gameInfo.isClientHost() && json.getString("page").equals("start")
        && json.getString("nextPage").equals("play")) {
      trySwitchPage(new PlayPage(getPreviousPage()));
    }
    return true;
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageOverlay, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
    text("Winning the Game", 300, 110);
  }
}

// Local Multiplayer Instructions Page
public class HelpPage6 extends Page {
  private PImage imageOverlay;
  private PImage instructionImage;
  
  public HelpPage6(Page previousPage) {
    super("help6", previousPage);
    this.imageOverlay = loadImage(imagePathHelpPageOverlay);
    this.instructionImage = loadImage(instructionSet6);

    // Back to Start Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Back",
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
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) { return false; }
    if (gameInfo.isClientHost() && json.getString("page").equals("start")
        && json.getString("nextPage").equals("play")) {
      trySwitchPage(new PlayPage(getPreviousPage()));
    }
    return true;
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageOverlay, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
    text("Local Multiplayer", 300, 110);
  }
}

// Online Multiplayer Instructions Page
public class HelpPage7 extends Page {
  private PImage imageOverlay;
  private PImage instructionImage;
  
  public HelpPage7(Page previousPage) {
    super("help7", previousPage);
    this.imageOverlay = loadImage(imagePathHelpPageOverlay);
    this.instructionImage = loadImage(instructionSet7);

    // Back to Start Page button
    Button backButton = new Button("ButtonBack", 200, 40, "Back",
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
  public boolean dispatchSyncInfo(JSONObject json) {
    if (!super.dispatchSyncInfo(json)) { return false; }
    if (gameInfo.isClientHost() && json.getString("page").equals("start")
        && json.getString("nextPage").equals("play")) {
      trySwitchPage(new PlayPage(getPreviousPage()));
    }
    return true;
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.imageOverlay, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
    image(this.instructionImage, 58, 150, 720, 334);
  }

  @Override
  public void draw() {
    super.draw();
    fill(255);
    textSize(25);
    text("Online Multiplayer", 300, 110);
  }
}
