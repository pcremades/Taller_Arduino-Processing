/* Copyright 2015 Pablo Cremades
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
/**************************************************************************************
* Autor: Pablo Cremades
* Fecha: 3/11/2015
* e-mail: pcremades@fcen.uncu.edu.ar.
* Descripción: Hace seguimiento de un objeto basado en sustracción del fondo y un algoritmo de
* decisión bayesiano.
* Con click derecho puede fijar dos puntos de referencia para establecer la escala.
*
* Change Log:
* 
* To do:
* - Que calcule la distancia de referencia y use el dato para corregir la posición.
*
*/

import processing.video.*;

float RThreshold = 150;
float Rstdv = 1;
float GThreshold = 100;
float Gstdv = 1;
float BThreshold = 100;
float Bstdv = 1;
int n=1;
int printPos = 0;
int refStatus = 0;
float ref1x, ref1y, ref2x, ref2y;
int clip1x, clip1y, clip2x, clip2y;

float meanX;
float meanY;

float mx = -1000;
float mn = 1000;
float PosX, PosY, oldPosX, oldPosY;
int lookformax;
float Period, timePeriod, delta, escala;
float time, vs;
float amplitud, amplitudIni, timeTau, Tau;
int trackAmpli=0;
float[] imageMeanR;
float[] imageMeanG;
float[] imageMeanB;
float[] imageVarR;
float[] imageVarG;
float[] imageVarB;

int[] newImage;

Capture video;

void setup() {
  size(640, 480);
  // Uses the default video input, see the reference if this causes an error
  String camaras[] = video.list();
  println(camaras);
  video = new Capture(this, camaras[5]);
  video.start();  
  noStroke();
  smooth();
  imageMeanR = new float[width*height];
  imageVarR = new float[width*height];
  imageMeanG = new float[width*height];
  imageVarG = new float[width*height];
  imageMeanB = new float[width*height];
  imageVarB = new float[width*height];
  
  newImage = new int[width*height];
}

void draw() {
  textSize(20);
  if (video.available()) {
    video.read();  //Lee un frame de la camara
    //image(video, 0, 0, width, height); // Dibuja el frame en la pantalla
    float brightestValue = 0;
    
    video.loadPixels();  //Lee los pixeles de la imagen en el vector 'pixeles' del objeto 'video'
    int index = 0;
    //Escanea la imagen 
    for (int y = clip1y; y < clip2y; y++) { //video.height-
      for (int x = clip1x; x < clip2x; x++) { //video.width-
        // Get the color stored in the pixel
        int pixelValue = video.pixels[index];  //Lee el pixel actual
        // Determine the brightness of the pixel
        float pixelBrightness = brightness(pixelValue);  //Determina el nivel de brillo
        int currR = (pixelValue >> 16) & 0xFF;  //Lee la componente roja
        int currG = (pixelValue >> 8) & 0xFF;  //Lee la componente verde
        int currB = pixelValue & 0xFF;    //Lee la componente azul
        
        if( abs(currR - imageMeanR[index]) > 2.0*sqrt(imageVarR[index]) || 
            abs(currG - imageMeanG[index]) > 2.0*sqrt(imageVarG[index]) ||
            abs(currB - imageMeanB[index]) > 2.0*sqrt(imageVarB[index]) ){
          meanX = meanX + x;  //Agrega la información del nuevo pixel.
          meanX /= 2.0;
          meanY = meanY + y;
          meanY /= 2.0;
        }
        
        if(printPos == 1){
          float RMeanOld = imageMeanR[index];
          float GMeanOld = imageMeanG[index];
          float BMeanOld = imageMeanB[index];
          imageMeanR[index] = ((n-1)*imageMeanR[index] + currR)/float(n);
          imageMeanG[index] = ((n-1)*imageMeanG[index] + currG)/float(n);
          imageMeanB[index] = ((n-1)*imageMeanB[index] + currB)/float(n);
          
          imageVarR[index] = ((n-1)*imageVarR[index] + (currR - RMeanOld)*(currR - imageMeanR[index]))/float(n);
          imageVarG[index] = ((n-1)*imageVarG[index] + (currG - GMeanOld)*(currG - imageMeanG[index]))/float(n);
          imageVarB[index] = ((n-1)*imageVarB[index] + (currB - BMeanOld)*(currB - imageMeanB[index]))/float(n);
          
          newImage[index] = video.pixels[index] - ((( (int(imageMeanR[index]) << 8) | int(imageMeanG[index]) ) << 8) | int(imageMeanB[index]));
          video.pixels[index] = newImage[index];
        }
        //index++;
        index = y*width + x;
      }
    }
    video.loadPixels();
    image(video, 0, 0, width, height); // Dibuja el frame en la pantalla
// Dibuja un círculo sobre el objeto que se sigue y los puntos de referencia.
    fill(255, 204, 0, 128);
    ellipse(meanX, meanY, 100, 100);
    fill(0, 104, 255, 128);
    ellipse(ref1x, ref1y, 10, 10);
    fill(0, 255, 104, 128);
    ellipse(ref2x, ref2y, 10, 10);
    noFill();
    stroke(200);
    rect( clip1x, clip1y, clip2x - clip1x, clip2y - clip1y);
    noStroke();
  }
  
  
  //Algoritmo para buscar los máximos y mínimos. (ref. http://www.billauer.co.il/peakdet.html)
  float ps = meanY;
  if( ps > mx )
    mx = ps;
  if( ps < mn )
    mn = ps;
  if( lookformax == 1 ){
    if( ps < mx-delta ){  //Encontró un máximo
      amplitud = abs(mx - mn);  //Calcula la amplitud actual
      mn = ps;
      lookformax = 0;
      Period =  (millis() - timePeriod)*2.0;  //Calcula el período.
      timePeriod = millis();  //Guarda el instante en que ocurrió el máximo.
      //println(Period);
    }
  }
  else{
    if( ps > mn+delta ){  //Encontró un mínimo
      amplitud = abs(mx - mn);  //Calcula la amplitud actual.
      mx = ps;
      lookformax = 1;
      Period =  (Period + (millis() - timePeriod)*2.0)/2;  //Calcula el período.
      timePeriod = millis();  //Guarda el instante en que ocurrió el mínimo.
    }
  }
  fill(255, 0, 130);
  text("Periodo [ms] = ", 300, 50);
  text(int(Period), 500, 50);
  text("Amplitud [m] = ", 300, 70);
  text(amplitud/escala, 500, 70);
  text("Tau [s] = ", 300, 90);
  text(Tau/1000, 500, 90);
  
  
  //Comienza a imprimir la información de posición.
  if( keyPressed ){
    if( key == 'b' ){  //Iniciar Background recording
      printPos = 1;
    }
    else if( key == 's' ){  //Iniciar tracking de amplitud.
     amplitudIni = amplitud;
     timeTau = millis();
     trackAmpli = 1;
    }
    else if( key == 'r' ){
      timeTau = 0;
      Tau = 0;
      trackAmpli = 0;
    }
  }
  
  if( mousePressed ){
    if( mouseButton == RIGHT ){  //Marca los puntos de referencia.
      if( refStatus == 0 ){
       refStatus = 1;
       ref1x = mouseX;
       ref1y = mouseY;
       delay(100);
      }
      else if( refStatus == 1 ){
       refStatus = 0;
       ref2x = mouseX;
       ref2y = mouseY;
       delay(100);
      }
      //Escala basada en 2 marcas separadas 25cm o 0.25m.
      escala = sqrt( (ref1x - ref2x)*(ref1x - ref2x) + (ref1y - ref2y)*(ref1y - ref2y) )/0.25;
    }
    if( mouseButton == LEFT ){  //Marca los puntos de referencia.
      if( refStatus == 0 ){
       refStatus = 1;
       clip1x = mouseX;
       clip1y = mouseY;
       delay(100);
      }
      else if( refStatus == 1 ){
       refStatus = 0;
       clip2x = mouseX;
       clip2y = mouseY;
       delay(100);
      }
    }
  }
  
  if(printPos == 1){
    n++;
  }
  
  if(n > 30){
    n = 1;
    printPos=0;
  }
  
  if( (trackAmpli == 1) && (amplitud < 0.36*amplitudIni) ){
    Tau = millis() - timeTau;
    trackAmpli = 0;
  }
  
}