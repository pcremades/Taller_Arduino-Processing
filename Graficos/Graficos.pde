import grafica.*;

GPlot graf;

int i;
boolean freeze = false;

void setup(){
  size(800, 600);
  graf = new GPlot(this);
  graf.setPos( width/5, height/5);
  graf.setDim(500, 200);
  graf.getXAxis().setAxisLabelText("Tiempo [s]");
}

void draw(){
  graf.defaultDraw();
  int y = round(random(5.9));
  if( freeze == false){
  if(i > 50){
    graf.removePoint(0);
  }
  i++;
  graf.addPoint(millis(), y);
}
}

void keyPressed(){
 if( key == 'f')
   freeze = !freeze;
}