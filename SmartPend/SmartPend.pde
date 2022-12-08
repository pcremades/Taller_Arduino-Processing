/* Copyright 2016 Pablo Cremades
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
* Fecha: 19/10/2016
* e-mail: pcremades@fcen.uncu.edu.ar
* Descripción: Sistema de adquisición de datos de un péndulo utilizando un smartphone.
* El smartphone debe tener instalada la app iMecaProf (https://sites.google.com/site/joelchevrier/imecaprof).
* Ésta envía un string CVS usando el protocolo UDP.
* El programa en la PC recibe los datos de los acelerómetros. En este caso se utilizan
* los ejes Y y Z para calcular la posición instantánea del péndulo. El smartphone debe
* colocarse en el pivote del péndulo para evitar el problema del principio de equivalencia.
* Esto es, el acelerómetro no puede distinguir entre la aceleración de la gravedad y
* una aceleración en un sistema de referencia no inercial.
*
* Uso:
* 1) Abrir la aplicación iMecaProf en el smartphone.
* 2) Configurarla para enviar los datos a la PC por el puerto 10552.
* 3) Asegurarse que esté transmitiendo los datos de los acelerómetros.
* 4) Iniciar la aplicación en la PC.
*
* Change Log:
*
*/

import hypermedia.net.*;
import java.net.InetAddress;
UDP udp;

String input;
int data[];
float[] sensData;
float accX, accY, accZ;
float[] yPos;
int nyPos = 300, iyPos;
float angle;
float L = 100;

float amplitud, amplitudIni;
float mx=-1000, mn=1000, lookformax=1, delta=10;
float timePeriod, Period;

void setup() { 
  size(640, 480); 
  background(204);
  stroke(0);
  frameRate(30); // Slow it down a little
  // Connect to the server’s IP address and port­
  udp = new UDP(this, 10552); // Replace with your server’s IP and port
  //udp.log( true );
  udp.listen( true );
  yPos = new float[nyPos];
}

void draw() {
  background(250);    
  //Compute angle
  angle = atan(-accZ/accY);
  stroke(0);
  strokeWeight(3);
  line(width/2, 0, width/2-sin(angle)*L, L+cos(angle)*L);
  fill(0, 230, 100);
  ellipse(width/2-sin(angle)*L, L+cos(angle)*L, 60, 60);
  
  //Draw previous positions
  noStroke();
  for(int i=nyPos-1; i>0; i--){
    fill(250, 250-i/300.0*250, 250-i/300.0*250);
    ellipse(yPos[i], L+130+nyPos-i, 5, 5); 
  }
  
  fill(0);
  //Algoritmo para buscar los máximos y mínimos. (ref. http://www.billauer.co.il/peakdet.html)
  float PeriodOld = Period;
  float ps = yPos[0];
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
      Period =  (millis() - timePeriod)*2.0;  //Calcula el período.
      timePeriod = millis();  //Guarda el instante en que ocurrió el mínimo.
    }
  }
  /*if( abs(angle) < 0.005 ){
   Period = millis() - timePeriod;
   Period = Period * 2;
   timePeriod = millis();
   println(angle);
  }*/
  Period += PeriodOld;
  Period /= 2;
  
  textSize(32);
  text("Período: "+round(Period/10)/100.0+"s", width*3/5, 50);
}

// Receive data from server
void receive( byte[] data, String ip, int port ){
  //Get CVS message
    String message = new String( data );
  //Parse string and get 3 accelerations
    sensData = float(split(message, ','));
    accX = sensData[1];
    accY = sensData[2];
    accZ = sensData[3];
    
    //LILO Buffer. Rotates the buffer and stores the new position.
    for(int i=0; i<nyPos-2; i++){
      yPos[i] = yPos[i+1];
    }
    yPos[nyPos-2] = width/2-sin(angle)*L;
}
