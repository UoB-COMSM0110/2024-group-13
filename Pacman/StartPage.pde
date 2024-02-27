// The first page of the game.
public class StartPage extends Page {
  public StartPage(GameInfo gInfo, Page previousPage) {
    super(gInfo, previousPage);
    Button helloWorldButton = new Button("ButtonHelloWorld", 200, 200, "Init");
    helloWorldButton.setW(200).setH(40);
    addLocalItem(helloWorldButton);
  }
}
