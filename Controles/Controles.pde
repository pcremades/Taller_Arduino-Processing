import processing.serial.*;

import g4p_controls.*;

GButton Iniciar;
GButton Detener;
GDropList lista;
void setup(){
  size( 800, 600);
  
  Iniciar = new GButton(this, width/4, height/2, 100, 30, "Iniciar");
  Detener = new GButton(this, width*3/4, height/2, 100, 30, "Detener");
 
  lista = new GDropList(this, 100, 100, 200, 100);
  String[] puertos = Serial.list();
  lista.setItems(puertos, 0);
}

void draw(){
  background(255);
}

void handleDropListEvents(GDropList list, GEvent event) { 
   println(list.getSelectedIndex());
}

void handleButtonEvents( GButton b, GEvent e){
  if( e == GEvent.CLICKED){
  if( b == Iniciar )
     println("Iniciar");
  else if( b == Detener )
     println("Detener");
     exit();
  }
}