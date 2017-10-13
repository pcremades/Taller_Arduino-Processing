import processing.serial.*;

Serial port;
String[] serialPorts;
String inString;

void setup(){
  size(400, 300);
  serialPorts = Serial.list(); //Lista de interfaces
  for( int i=0; i<serialPorts.length; i++){ //Buscar dispositivos serie cuyo nombre contenga "ttyACM"
    if( serialPorts[i].contains("ttyACM") ){  //Si lo encuentra intenta abrir.
                println(serialPorts[i]);
      try{
        port = new Serial(this, serialPorts[i], 115200);  //Abrir puerto.
        println( serialPorts[i] );
        port.bufferUntil(10);
      }
      catch(Exception e){  //Si hay algún problema, capturamos la excepción.
        println("Error al intentar abrir la interface "+
                serialPorts[i]+
                ". Verifique si tiene suficientes permisos.");
      }
    }
  }
  if( port == null ){
     println("No se encontró ninguna interface");
     exit();
    }
}

void draw(){
  
}

//Read the incoming data from the port.
void serialEvent(Serial port) { 
  inString = port.readString();
}