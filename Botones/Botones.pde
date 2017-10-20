import g4p_controls.*;

GButton Iniciar, Detener;

void setup(){
 size( 800, 600);
 Iniciar = new GButton(this, width/4, height/2, 100, 30, "Iniciar");
 Detener = new GButton(this, width*3/4, height/2, 100, 30, "Detener");
}

void draw(){
}

void handleButtonEvents( GButton b, GEvent e){
  if( e == GEvent.CLICKED){
  if( b == Iniciar )
     println("Iniciar");
  else if( b == Detener )
     println("Detener");
  }
}