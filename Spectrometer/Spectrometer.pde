import g4p_controls.*;
import grafica.*;
import processing.video.*;

GPlot graf;

GDropList camSel;
GButton Tare;
GButton unTare;

Capture video;
int SubImgX, SubImgY;
int SubImgH=15;

float[] Intensidad = new float[1800];
GPointsArray GIntensidad;
GPointsArray Cal;


int[] x={100, 300}, y={100, 100};
float theta;
int blueX = 200, greenX=300;
int blueWL = 436, greenWL = 546;  //Longitudes de onda correspondiente al azul y verde de lampara de mercurio.

void setup() {
  size(1280, 720);
  
  SubImgX=width/2; 
  SubImgY=height/2;
  
  Cal = new GPointsArray();

//Droplist de cámaras disponibles
  camSel = new GDropList(this, width/2+100, 50, 300, 150);
//Botón Calibrar
  Tare = new GButton(this, width/2 + 10, SubImgY + 200, 100, 20, "Calibrar");
//Botón para borrar la calibración
  unTare = new GButton(this, width/2 + 150, SubImgY + 200, 100, 20, "Borrar");

//Leer lista de cámaras y modos disponibles
  String[] camaras = Capture.list();
  int nCam = 0;
//Busca sólo las cámaras que puedan grabar a 10 fps. Es para reducir el número items en la lista.
  for ( int k=0; k < camaras.length; k++ ) {
    if ( camaras[k].contains("fps=10") )
      nCam++;
  }
//Crea un arreglo de strings para guardar la lista de cámara válidas.
  String[] camarasValid = new String[nCam+1];
  nCam=0;
  for ( int k=0; k < camaras.length; k++ ) {
    if ( camaras[k].contains("fps=10") ) {
      camarasValid[nCam] = camaras[k];
      nCam++;
    }
  }

  // Uses the default video input, see the reference if this causes an error
  try {
    video = new Capture(this, camarasValid[0]);
    video.start();
  }
  catch( Exception e ) {
    println("No hay cámaras HD conectadas");
    exit();
  }
  noStroke();
  smooth();

  camSel.setItems(camarasValid, 0);

//Configura el gráfico.
  graf = new GPlot(this);
  graf.setPos( SubImgX, height/3);
  graf.setDim(500, 200);
  graf.setFixedYLim(true);
  graf.setYLim(0.0, 1.0);
  graf.getXAxis().setAxisLabelText("Longitud de onda [nm]");
}


void draw() {
  if (video.available()) {
    GIntensidad = new GPointsArray();
    background(255);
    textSize(22);
    text("Seleccione la cámara: ", width/2+100, 30);
    video.read();
    image(video, 0, 0, width/2, height/2); // Draw the webcam video onto the screen
    video.loadPixels();
    //println(video.width + " " + video.height);
    for ( int i=x[0]*video.width/SubImgX; i<=x[1]*video.width/SubImgX; i++) {
      //for ( int j=0; j< SubImgH; j++) {
      // int Y = y[0]*video.height/SubImgY + round((i-x[0]*video.width/SubImgX)*theta) + j;
      int Y = y[0]*video.height/SubImgY + round((i-x[0]*video.width/SubImgX)*theta);
      int pixIndex = Y*video.width + i;
      int pixVal=0;
      if (pixIndex > video.width*video.height)
        println(pixIndex + " " + Y + " " + i);
      try {
        pixVal = video.pixels[pixIndex];
      }
      catch(Exception e) {
        println("Error: " + pixIndex + " " + Y + " " + i);
      }
      float pixelBrightness = brightness(pixVal);
      Intensidad[i] = pixelBrightness/256;
      int currR = (pixVal >> 16) & 0xFF;  //Lee la componente roja
      int currG = (pixVal >> 8) & 0xFF;  //Lee la componente verde
      int currB = pixVal & 0xFF;    //Lee la componente azul
      stroke(currR, currG, currB);
      for ( int j=0; j< SubImgH; j++) {
        point( SubImgX/2 + i-x[0]*video.width/SubImgX - (x[1]-x[0])/2*video.width/SubImgX, SubImgY+100+j);
        //graf.removePointAt(x[0], Intensidad[i]);
      }
      int iScaled = round(float(blueWL) + float(greenWL - blueWL)/float(greenX - blueX) * float((i-x[0]*video.width/SubImgX)-blueX)); ///(x[1]-x[0])*video.width/SubImgX
      
      try{
        float ggg = 1 - Intensidad[i] - Cal.getY(i - x[0]*video.width/SubImgX);
        GIntensidad.add(iScaled, ggg);
      }
      catch( Exception e){
        GIntensidad.add(iScaled, Intensidad[i]);
        textSize(12);
        text("Sin Calibrar", SubImgX+10, height/3 - 10);
      }
    }

    //Dibuja la línea seleccionada.
    noStroke();
    fill(0, 0, 250, 128);
    ellipse(x[0], y[0], 10, 10);
    fill(250, 0, 0, 128);
    ellipse(x[1], y[1], 10, 10);
    stroke(250, 250, 0, 128);
    line(x[0], y[0], x[1], y[1]);
    
    stroke(0, 0, 250, 200);
    strokeWeight(3);
    line( blueX+(SubImgX/2 - (x[1]-x[0])/2*video.width/SubImgX), SubImgY+90, blueX+(SubImgX/2 - (x[1]-x[0])/2*video.width/SubImgX), SubImgY+130);
    stroke(0, 250, 0, 200);
    strokeWeight(3);
    line( greenX+(SubImgX/2 - (x[1]-x[0])/2*video.width/SubImgX) , SubImgY+90, greenX+(SubImgX/2 - (x[1]-x[0])/2*video.width/SubImgX), SubImgY+130);

    graf.setPoints(GIntensidad);
    graf.beginDraw();
    graf.drawBackground();
    graf.drawBox();
    graf.drawXAxis();
    graf.drawYAxis();
    graf.drawTitle();
    graf.drawLines();
    graf.setHorizontalAxesTicksSeparation(30);
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

void keyPressed() {
  if(mouseX > SubImgX/2 - (x[1]-x[0])/2*video.width/SubImgX & mouseX < SubImgX/2 + (x[1]-x[0])/2*video.width/SubImgX)
  {
  switch( key ) {
  case 'b':
    blueX = mouseX - (SubImgX/2 - (x[1]-x[0])/2*video.width/SubImgX);
    println(blueX);
    break;
  case 'g':
    greenX = mouseX - (SubImgX/2 - (x[1]-x[0])/2*video.width/SubImgX);
    break;
  }
  }
}

void handleDropListEvents(GDropList list, GEvent event) { 
  video.stop();
  video = new Capture(this, camSel.getSelectedText());
  video.start();
}

void handleButtonEvents(GButton button, GEvent event) { 
  if( button == Tare )
    Cal.add(graf.getPoints());
  else if( button == unTare )
    Cal = new GPointsArray();
}