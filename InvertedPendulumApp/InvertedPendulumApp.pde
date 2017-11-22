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
* Fecha: 08/03/2017
* e-mail: pablocremades@gmail.com
* Descripción: Aplicación para registrar la posición de un móvil sobre el riel de aire
* utilizando el sensor ultrasónico. La aplicación también calcula la velocidad instantánea.
* Para comenzar a medir presione el botón "Iniciar". Cuando termine, presione el botón "Detener".
*
* Change Log:
***************************************************************************************/
import g4p_controls.*;
import processing.serial.*;
import grafica.*;

GButton Iniciar, Detener, X_MIN, X_MAX;

GPlot plotPos, plotAngle;
GPointsArray points;

String inString = "";
String[] serialPorts;
Serial port;

int nPoints = 0;

void setup(){
  size(900, 650);
  serialPorts = Serial.list(); //Get the list of tty interfaces
  for( int i=0; i<serialPorts.length; i++){ //Search for ttyACM*
    if( serialPorts[i].contains("ttyUSB") ){  //If found, try to open port.
                println(serialPorts[i]);
      try{
        port = new Serial(this, serialPorts[i], 115200);
        port.bufferUntil(10);
      }
      catch(Exception e){
      }
    }
  }
  
  // Create a new plot and set its position on the screen
  plotPos = new GPlot(this);
  plotPos.setPos(25, 25);
  plotPos.setDim(700, 200);
  plotPos.setYLim(-17, 17);
  plotPos.setTitleText("Posición");

  // Add the points
  //plotPos.setPoints(points);
  
  plotAngle = new GPlot(this);
  plotAngle.setPos(25, 330);
  plotAngle.setDim(700, 200);
  plotAngle.setYLim(-15, 15);

  // Set the plot title and the axis labels
  plotAngle.setTitleText("Ángulo");
}

void draw(){
  background(150);
  
  plotPos.beginDraw();
  plotPos.drawBackground();
  plotPos.drawBox();
  plotPos.drawXAxis();
  plotPos.drawYAxis();
  plotPos.drawTopAxis();
  plotPos.drawRightAxis();
  plotPos.drawTitle();
  plotPos.drawGridLines(GPlot.BOTH);
  plotPos.getXAxis().getAxisLabel().setText("Tiempo [ms]");
  plotPos.getYAxis().getAxisLabel().setText("Posición [cm]");
  plotPos.getMainLayer().drawPoints();
  plotPos.endDraw();
  
  plotAngle.beginDraw();
  plotAngle.drawBackground();
  plotAngle.drawBox();
  plotAngle.drawXAxis();
  plotAngle.drawYAxis();
  plotAngle.drawTopAxis();
  plotAngle.drawRightAxis();
  plotAngle.drawTitle();
  plotAngle.drawGridLines(GPlot.BOTH);
  plotAngle.getXAxis().getAxisLabel().setText("Tiempo [ms]");
  plotAngle.getYAxis().getAxisLabel().setText("Ángulo [grad]");
  plotAngle.getMainLayer().drawPoints();
  plotAngle.endDraw();
  
  if(inString.length() > 10 && inString.contains("Hasta") == false){
    String[] datos = split(inString, ' ');
    float angle = float(datos[0])/1500.0*360;
    float pos = (float(datos[1]) - 1700.0)/300*2.54;
        println(angle + "  ---  " + pos);
    if( nPoints > 100){
      plotPos.removePoint(0);
      plotPos.addPoint(millis(), pos);
      plotAngle.removePoint(0);
      plotAngle.addPoint(millis(), angle);
    }
    else{
      plotPos.addPoint(millis(), pos);
       plotAngle.addPoint(millis(), angle);
       nPoints++;
    }
    inString = "";
  }
}

//Read the incoming data from the port.
void serialEvent(Serial port) { 
  inString = port.readString();
}