import processing.serial.*;

Serial port;

int altura = 300;
int ancho = 300;
int initX, initY;
int patternSize = 100;
int patternN = (altura/patternSize * ancho/patternSize);
int i = patternN;

void setup() {
  size(800, 600);
  initX = width-ancho;
  initY = height-altura;
  //frameRate(10);
  if ( openComm() == 1 ) {
    println( "No hay ningún colorímetro conectado" );
    exit();
  }
}

float freq;
float maxFreq;
float[] img = new float[patternN];
int iter = 20;

void draw() {
  //println(initX, initY);
  delay(20);
  readSensor();
  println(freqMean);
  delay(10);

  background(255);
  fill(0); 
  stroke(0);
  rect(initX, initY, width, height);
  if ( iter > 0 ) {
    delay(100);
    readSensor();
    iter--;
  } else {
    newPattern( patternN - i );
    i--;
    if ( i <= 0 ) {
      for ( int j = 0; j<patternN; j++) {
        if (img[j] > maxFreq)
          maxFreq = img[j];
      }
      i = patternN;
      for ( int j = 0; j<patternN; j++) {
        img[j] = img[j]/maxFreq*255;
        println(img[j]);
        fill(img[j]);
        stroke(img[j]);
        int y = j / (ancho / patternSize);
        int x = j - (y*(ancho/patternSize));
        rect(x*patternSize, y*patternSize, patternSize, patternSize);
      }
      noLoop();
    } else {
      img[patternN - i] = freqMean;
      //println(patternN -i + "   " +freq);
    }
  }
}

int c;
void newPattern( int k ) {
  int y = k / (ancho / patternSize);
  int x = k - (y*(ancho/patternSize));
  //println("k="+k+"   x="+x+"  y="+y);
  //int colorRand = round(random(0, 255));
  int colorRand = round(map(k, 0, patternN, 0, 255));
  fill(colorRand);
  stroke(colorRand);
  rect(initX + x*patternSize, initY + y*patternSize, patternSize, patternSize);
  //rect(initX, initY, patternSize, patternSize);
  /*fill(c); stroke(c);
   rect(initX, initY, width, height);
   c++;
   if(c > 255)
   c= 0;*/
}

float freqMean;
void readSensor() {
  freqMean = 0;
  for ( int i=0; i<5; i++) {
    port.write('R');
    delay(150);
    freqMean += freq;
  }
}


int openComm() {
  String[] serialPorts = Serial.list(); //Get the list of tty interfaces
  for ( int i=0; i<serialPorts.length; i++) { //Search for ttyACM*
    if ( serialPorts[i].contains("ttyACM") || serialPorts[i].contains("ttyUSB0") || serialPorts[i].contains("COM") ) {  //If found, try to open port.
      println(serialPorts[i]);
      try {
        port = new Serial(this, serialPorts[i], 115200);
        port.bufferUntil(10);
      }
      catch(Exception e) {
        return 1;
      }
    }
  }
  if (port != null)
    return 0;
  else
    return 1;
}

void serialEvent(Serial port) { 
  String inString = port.readString();

  //Buscamos un string válido.
  if ( inString.length() > 3 ) {
    try {
      freq = float( inString );
    }
    catch(Exception e) {
    }
  }
  //print(inString);
  inString ="";
}
