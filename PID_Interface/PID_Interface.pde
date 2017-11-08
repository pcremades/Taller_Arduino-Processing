import processing.serial.*;

import g4p_controls.*;

GTextField kp;
GTextField ki;
GTextField kd;

GButton Set;

Serial puerto;

void setup(){
 size(800, 600);
 kp = new GTextField(this, 100, 100, 100, 30);
 kp.setText("1");
 ki = new GTextField(this, 300, 100, 100, 30);
 ki.setText("1");
 kd = new GTextField(this, 600, 100, 100, 30);
 kd.setText("1");
 
 Set = new GButton(this, 100, 300, 100, 50, "SET");
 
 puerto = new Serial(this, "/dev/ttyUSB0", 115200);
}

void draw(){
}

void SerialEvent( Serial p){
   String inString = p.readString();
   println(inString);
}


void handleButtonEvents(GButton button, GEvent event) {
   if(button == Set && event == GEvent.CLICKED){
       float kpf = float(kp.getText());
       float kif = float(ki.getText());
       float kdf = float(kd.getText());
       println(kpf,kif,kdf);
   }
}