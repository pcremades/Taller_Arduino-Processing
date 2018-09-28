import processing.serial.*;

Serial port;

int altura = 300;
int ancho = 300;
int initX, initY;
int patternSize = 30;
int patternN = (altura/patternSize * ancho/patternSize);
int i = patternN;

void setup(){
  size(800, 600);
  initX = width-ancho;
  initY = height-altura;
  frameRate(10);
   if( openComm() == 1 ){
   println( "No hay ningún colorímetro conectado" );
   exit();
   }
}

void draw(){
  //println(initX, initY);
  background(255);
  fill(0); stroke(0);
  rect(initX, initY, width, height);
  newPattern( patternN - i );
  readSensor();
  delay(5000);
  i--;
  if( i <= 0 ){
    i = patternN;
    //noLoop();
  }
}

int c;
void newPattern( int k ){
  /*int y = k / (ancho / patternSize);
  int x = k - (y*(ancho/patternSize));
  //println("k="+k+"   x="+x+"  y="+y);
  int colorRand = round(random(0, 255));
  fill(colorRand);
  stroke(colorRand);
  rect(initX + x*patternSize, initY + y*patternSize, patternSize, patternSize);*/
  fill(c); stroke(c);
  rect(initX, initY, width, height);
  c++;
  if(c > 255)
    c= 0;
}

void readSensor(){
  port.write("[1]\n");
  //port.clear();  
}


int openComm() {
  String[] serialPorts = Serial.list(); //Get the list of tty interfaces
  for ( int i=0; i<serialPorts.length; i++) { //Search for ttyACM*
    if ( serialPorts[i].contains("ttyACM") || serialPorts[i].contains("ttyUSB0") || serialPorts[i].contains("COM") ) {  //If found, try to open port.
      println(serialPorts[i]);
      try {
        port = new Serial(this, serialPorts[i], 9600);
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
      //println(inString);

  //Buscamos un string válido.
  if ( inString.length() > 30 && inString.charAt(0) == '[' ) {
    try{
    String[] list = split(inString, ","); //Split the string.
    //println(list[4]);
    float[] freq = {float( list[1] ), float( list[2] ), float( list[3] ), float( list[4] )};
    //float[] trans = {float( list[5] ), float( list[6] ), float( list[7] )};
    println(freq[3]);
  }
  catch(Exception e){}
  }
  inString ="";
}