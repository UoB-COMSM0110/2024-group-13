import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Comparator; 

static final String leaderboardFile = "data/leaderboard.csv";

public class GameOverPage extends Page {
  private String winnerMessage;
  private int player1Score;
  private int player2Score;
  private List<String> topScores;

  public GameOverPage(int player1Score, int player2Score, Page previousPage) {
    super("gameover", previousPage);
    this.player1Score = player1Score;
    this.player2Score = player2Score;

    writeScoreToFile(gameInfo.getPlayerName1(), player1Score);
    writeScoreToFile(gameInfo.getPlayerName2(), player2Score);
    this.topScores = readAndSortScores();

    if (player1Score > player2Score) {
      this.winnerMessage = gameInfo.getPlayerName1() + "  Wins!";
    }
    if (player2Score > player1Score) {
      this.winnerMessage = gameInfo.getPlayerName2() + "  Wins!";
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


  class PlayerScore {
      String playerName;
      int score;
  
      PlayerScore(String playerName, int score) {
          this.playerName = playerName;
          this.score = score;
      }
  }
  
  public List<String> readAndSortScores() {
      Table scoresTable = loadTable(leaderboardFile, "header");
      if (scoresTable == null) {
          System.out.println("No data found in leaderboard file.");
          return new ArrayList<>();
      }
  
      List<PlayerScore> scores = new ArrayList<>();
      for (TableRow row : scoresTable.rows()) {
          String playerName = row.getString("PlayerName");
          int score = row.getInt("Score");
          scores.add(new PlayerScore(playerName, score));
          System.out.println("Read row: " + playerName + ", " + score);
      }
  
      scores.sort((s1, s2) -> Integer.compare(s2.score, s1.score));
      System.out.println("After sorting:");
      for (PlayerScore score : scores) {
          System.out.println("Sorted row: " + score.playerName + ", " + score.score);
      }
  
      List<String> topScores = new ArrayList<>();
      for (int i = 0; i < Math.min(5, scores.size()); i++) {
          PlayerScore score = scores.get(i);
          topScores.add(score.playerName + ": " + score.score);
          System.out.println("Adding to topScores: " + score.playerName + ": " + score.score);
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

    String scoreMessage = this.player1Score + "  vs  " + this.player2Score;
    drawTextWithOutline(scoreMessage, 410, 150, 60, 5, color(255));
    drawTextWithOutline(winnerMessage, 410, 250, 60, 5, color(255));

    textSize(32); 
    int yPos = 350; 
    int counter = 1;

    drawTextWithOutline("Highscores", 400, 310, 32, 3, color(255));

    for(String scoreLine : this.topScores) {
      drawTextWithOutline(counter + ". " + scoreLine, 400, yPos, 32, 3, color(255)); 
      counter++;
      yPos += 40; 
    }
  }
}

public class ScoreComparator implements Comparator<TableRow> {
    @Override
    public int compare(TableRow r1, TableRow r2) {
        int score1 = r1.getInt("Score");
        int score2 = r2.getInt("Score");
        return score2 - score1; // For descending order
    }
  }
