import grafica.*;
import processing.video.*;

GPlot graf;

Capture video;
int SubImgX, SubImgY;
int SubImgH=5;

float[] Intensidad = new float[800];
GPointsArray GIntensidad;


int[] x={0, 0}, y={0, 0};
void setup() {
  size(800, 600);
  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, width, height);
  video.start();  
  noStroke();
  smooth();

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
    for ( int i=x[0]; i<=x[1]; i++) {
      for( int j=0; j< SubImgH; j++){
      int pixIndex = (y[0]*width/SubImgX+j)*width + i*width/SubImgX;
      int pixVal = video.pixels[pixIndex];
      float pixelBrightness = brightness(pixVal);
      Intensidad[i-x[0]] = pixelBrightness/256;
      int currR = (pixVal >> 16) & 0xFF;  //Lee la componente roja
      int currG = (pixVal >> 8) & 0xFF;  //Lee la componente verde
      int currB = pixVal & 0xFF;    //Lee la componente azul
      stroke((currR + currG + currB)/3);
      point( SubImgX + i, 200+j);
      //graf.removePointAt(x[0], Intensidad[i]);
      }
       GIntensidad.add(i, Intensidad[i-x[0]]);
    }

    //Dibuja la línea seleccionada.
    noStroke();
    fill(0, 0, 250, 128);
    ellipse(x[0], y[0], 10, 10);
    fill(250, 0, 0, 128);
    ellipse(x[1], y[1], 10, 10);
    stroke(250, 250, 0, 128);
    line(x[0], y[0], x[1], y[1]);
    
    graf.defaultDraw();
    graf.setPoints(GIntensidad);
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
}