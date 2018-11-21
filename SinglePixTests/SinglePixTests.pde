import processing.serial.*;

Serial port;
float freq;

void setup() {
  size(800, 600);
  //frameRate(10);
  if ( openComm() == 1 ) {
    println( "No hay ningún colorímetro conectado" );
    exit();
  }
}

int i=0;
int iMax = 256;
boolean dato = false;
void draw(){
    dato = false;
  int b = round(map(i, 0, iMax, 0, 255));
  println(i+ "   " +freq);
  background(i);
  i++;
  while( dato == false ){ println(dato); }
  if( i > iMax )
    i=0;
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
  dato = true;

  //Buscamos un string válido.
  if ( inString.length() > 1 ) {
    try {
      freq = float( inString );
      println("y..." + freq);
    }
    catch(Exception e) {
    }
  }
  inString ="";
}