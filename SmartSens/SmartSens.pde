import hypermedia.net.*;

UDP udp;

String input;
int data[];
float[] sensData;
float accX, accY, accZ;
float[] yPos;
int nyPos = 300, iyPos;
float angle;
float L = 100;
int time;

void setup() { 
  size(640, 480); 
  background(204);
  stroke(0);
  frameRate(30); // Slow it down a little
  // Connect to the server’s IP address and port­
  udp = new UDP(this, 10552); // Replace with your server’s IP and port
  //udp.log( true );
  udp.listen( true );
  rectMode(CENTER);
  yPos = new float[nyPos];
}

void draw() {
  background(250);
  translate(width/2, height/2);
  rotate(angle);
  angle = atan(-accX/accY);
  stroke(0);
  strokeWeight(3);
  fill(0, 230, 100);
  rect(0, 0, 60, 90);
  noStroke();
}

// Receive data from server
void receive( byte[] data, String ip, int port ){
    //print(millis() - time+"  ");
    time = millis();
    String message = new String( data );
    sensData = float(split(message, ','));
    accX = sensData[1];
    accY = sensData[2];
    accZ = sensData[3];
    
    //println(message.length());
}