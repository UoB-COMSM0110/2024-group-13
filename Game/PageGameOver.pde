import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;


static final String leaderboardFile = "data/leaderboard.csv";

public class GameOverPage extends Page {
  private String winnerMessage;
  private List<String> topScores;

  public GameOverPage(int player1Score, int player2Score, Page previousPage) {
    super("gameover", previousPage);

    writeScoreToFile(gameInfo.getPlayerName1(), player1Score);
    writeScoreToFile(gameInfo.getPlayerName2(), player2Score);
    this.topScores = readAndSortScores();

    if (player1Score > player2Score) {
      this.winnerMessage = gameInfo.getPlayerName1() + " Wins!";
    }
    if (player2Score > player1Score) {
      this.winnerMessage = gameInfo.getPlayerName2() + " Wins!";
    }
    if (player1Score == player2Score) {
      this.winnerMessage = "It's a draw!";
    }

    Button backButton = new Button("ButtonBack", 200, 40, "Back",
        () -> { trySwitchPage(getPreviousPage()); });
    backButton.setX(55).setY(28);
    addLocalItem(backButton);
  }

  public void writeScoreToFile(String playerName, int score) {
    Table scoresTable = loadTable(leaderboardFile, "header");
    if (scoresTable == null) {
      scoresTable = new Table();
      scoresTable.addColumn("PlayerName");
      scoresTable.addColumn("Score");
    }

    TableRow newRow = scoresTable.addRow();
    newRow.setString("PlayerName", playerName);
    newRow.setInt("Score", score);

    saveTable(scoresTable, leaderboardFile);
  }


  public List<String> readAndSortScores() {
    Table scoresTable = loadTable(leaderboardFile, "header");
    if (scoresTable == null) {
      return new ArrayList<>(); 
    }

    scoresTable.sortReverse("Score");

    List<String> topScores = new ArrayList<>();
    for (int i = 0; i < Math.min(5, scoresTable.getRowCount()); i++) {
      TableRow row = scoresTable.getRow(i);
      String playerName = row.getString("PlayerName");
      int score = row.getInt("Score");
      topScores.add(playerName + ": " + score);
    }

    return topScores;
  }

  @Override
  public void drawBackground() {
    image(imageStartPageBackground, 0, 0, gameInfo.getWinWidth(), gameInfo.getWinHeight());
  }

  @Override
  public void draw() {
    super.draw();

    drawTextWithOutline(winnerMessage, 410, 200, 60, 5, color(255));

    textSize(32); 
    int yPos = 350; 
    int counter = 1;

    drawTextWithOutline("Highscores", 370, 310, 32, 3, color(255));

    for(String scoreLine : this.topScores) {
      drawTextWithOutline(counter + ". " + scoreLine, 370, yPos, 32, 3, color(255)); 
      counter++;
      yPos += 40; 
    }
  }

  // Helper method to draw text with an outline
  void drawTextWithOutline(String text, float x, float y, float textSize, int outlineOffset, color textColor) {
    textSize(textSize);

    // Draw the outline
    fill(116, 54, 18); 
    for (int dx = -outlineOffset; dx <= outlineOffset; dx++) {
      for (int dy = -outlineOffset; dy <= outlineOffset; dy++) {
        if (dx != 0 || dy != 0) { 
          text(text, x + dx, y + dy);
        }
      }
    }

    fill(textColor); 
    text(text, x, y);
  }
}
