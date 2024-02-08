import processing.net.*;

Server server;

Client client;
int s_port = 2048;
String s_ip = "137.222.135.228";
// String s_ip = "137.222.135.231";

int numFrames = 0;
int ts = 20;

void setup() {
  server = new Server(this, s_port);
  println("Server created.");
  client = new Client(this, s_ip, s_port);
  println("Client created.");

  size(800, 600);
  frameRate(100);
}

void draw() {
  background(205);
  numFrames += 1;
  textSize(ts);
  text(hour() + ":" + minute() + ":" + second(), ts, ts);
  text("nframe: " + numFrames, ts, 2 * ts);
  text("ip: " + client.ip(), ts, 3 * ts);

  client.write(second() + "s " + client.ip());
  if (client.available() > 0) {
    text("server said: " + client.readString(), ts, 5 * ts);
  } else {
    text("server said nothing", ts, 5 * ts);
  }

  int n = 0;
  while (true) {
    Client listener = server.available();
    if (listener == null) {
      break;
    }
    ++n;
    if (listener.available() > 0) {
      text("listener " + listener.ip() + " said: "
          + listener.readString(), ts, (n + 10) * ts);
    } else {
      text("listener " + listener.ip() + " said nothing",
          ts, (n + 10) * ts);
    }
    // listener.write(" " + n);
  }
  if (n > 0) {
    server.write(second() + "s " + client.ip() + " n=" + n);
  }
}
