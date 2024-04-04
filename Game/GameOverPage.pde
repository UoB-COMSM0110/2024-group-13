
public class GameOverPage extends Page {
  
  private String winnerMessage;
  
  public GameOverPage(int player1Score, int player2Score, Page previousPage) {
    super(previousPage);
    
    if(player1Score > player2Score){
      winnerMessage = gameInfo.getPlayerName1()+" Wins!";
    }
    if(player2Score > player1Score){
      winnerMessage = gameInfo.getPlayerName2()+" Wins!";
    }
    else{
      winnerMessage = "It's a draw!";
    }
    
    Button exitButton = new Button("ButtonBack", 200, 40, "Exit", () -> {
      
      trySwitchPage(new StartPage(this));
    });
    exitButton.setX(55).setY(28);
    addLocalItem(exitButton);
  }

@Override
public void draw() {
  image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
  // Outline color
  fill(116, 54, 18); // Black outline
  textSize(60);
  // Draw the text multiple times around the original position to create the outline
  // Adjust the offsets if you want a thicker or thinner outline
  int offset = 5; // Offset for the outline. Increase for a thicker outline.
  for (int dx = -offset; dx <= offset; dx++) {
    for (int dy = -offset; dy <= offset; dy++) {
      if (dx != 0 || dy != 0) { // Avoid drawing the outline on top of the main text
        text(winnerMessage, 410 + dx, 300 + dy);
      }
    }
  }
  
  // Original text color and position
  fill(255); // Original text color
  text(winnerMessage, 410, 300); // Original text position
  
  super.draw();
}
}
