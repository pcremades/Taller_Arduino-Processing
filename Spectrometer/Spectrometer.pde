import g4p_controls.*;
import grafica.*;
import processing.video.*;

GPlot graf;

GDropList camSel;

Capture video;
int SubImgX, SubImgY;
int SubImgH=15;

float[] Intensidad = new float[1800];
GPointsArray GIntensidad;


int[] x={100, 300}, y={100, 100};
float theta;

void setup() {
  size(1280, 720);
  
  camSel = new GDropList(this, width/2+100, 30, 300, 150);
  String[] camaras = Capture.list();
  int nCam = 0;
  for( int k=0; k < camaras.length; k++ ){
   if( camaras[k].contains("720") )
     nCam++;
  }
  String[] camarasValid = new String[nCam+1];
  nCam=0;
  for( int k=0; k < camaras.length; k++ ){
   if( camaras[k].contains("720") ){
     camarasValid[nCam] = camaras[k];
     nCam++;
   }
  }
  
  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, camarasValid[0]);
  video.start();  
  noStroke();
  smooth();
  
  camSel.setItems(camarasValid,0);

  SubImgX=width/2; 
  SubImgY=height/2;
  
  graf = new GPlot(this);
  graf.setPos( 100, height/2);
  graf.setDim(500, 200);
  graf.setFixedYLim(true);
  graf.setYLim(0.0, 1.0);
  graf.getXAxis().setAxisLabelText("Longitud de onda [nm]");
}


void draw() {
  if (video.available()) {
    GIntensidad = new GPointsArray(800);
    background(255);
    video.read();
    image(video, 0, 0, width/2, height/2); // Draw the webcam video onto the screen
    video.loadPixels();
    //println(video.width + " " + video.height);
    for ( int i=x[0]*2; i<=x[1]*2; i++) {
     for( int j=0; j< SubImgH; j++){
       int Y = y[0]*2 + round((i-x[0]*2)*theta) + j;
      int pixIndex = Y*width + i;
      int pixVal=0;
      if(pixIndex > 1280*720)
        println(pixIndex + " " + Y + " " + i);
        try{
        pixVal = video.pixels[pixIndex];
      }
      catch(Exception e){
        println("Error: " + pixIndex + " " + Y + " " + i);
      }
      float pixelBrightness = brightness(pixVal);
      Intensidad[i] = pixelBrightness/256;
      int currR = (pixVal >> 16) & 0xFF;  //Lee la componente roja
      int currG = (pixVal >> 8) & 0xFF;  //Lee la componente verde
      int currB = pixVal & 0xFF;    //Lee la componente azul
      stroke((currR + currG + currB)/3);
      point( SubImgX + i-x[0]*2, 200+j);
      //graf.removePointAt(x[0], Intensidad[i]);
     }
       GIntensidad.add(i, Intensidad[i]);
    }

    //Dibuja la línea seleccionada.
    noStroke();
    fill(0, 0, 250, 128);
    ellipse(x[0], y[0], 10, 10);
    fill(250, 0, 0, 128);
    ellipse(x[1], y[1], 10, 10);
    stroke(250, 250, 0, 128);
    line(x[0], y[0], x[1], y[1]);
    
    graf.setPoints(GIntensidad);
    graf.beginDraw();
    graf.drawBackground();
    graf.drawBox();
    graf.drawXAxis();
    graf.drawYAxis();
    graf.drawTitle();
    graf.drawLines();
    graf.endDraw();
  }
}

void mouseClicked() {
  if ( mouseX <= SubImgX && mouseY <= SubImgY ) {
    if (mouseButton == LEFT) {
      x[0] = mouseX;
      y[0] = mouseY;
    } else if (mouseButton == RIGHT) {
      x[1] = mouseX;
      y[1] = mouseY;
    }
  }
  theta = float(y[1]-y[0])/float(x[1]-x[0]);
  //println(theta);
}

void handleDropListEvents(GDropList list, GEvent event) { 
   video.stop();
   video = new Capture(this, camSel.getSelectedText());
   video.start();
}