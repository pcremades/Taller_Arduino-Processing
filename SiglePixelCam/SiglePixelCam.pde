int altura = 300;
int ancho = 300;
int initX, initY;
int patternSize = 30;
int patternN = (altura/patternSize * ancho/patternSize);
int i = patternN;

void setup(){
  size(800, 600);
  initX = width-ancho;
  initY = height-altura;
  frameRate(5);
}

void draw(){
  println(initX, initY);
  background(255);
  fill(0); stroke(0);
  rect(initX, initY, width, height);
  newPattern( patternN - i );
  readSensor();
  i--;
  if( i <= 0 )
    i = patternN;
}

void newPattern( int k ){
  int y = k / (ancho / patternSize);
  int x = k - (y*(ancho/patternSize));
  println("k="+k+"   x="+x+"  y="+y);
  int colorRand = round(random(0, 255));
  fill(colorRand);
  stroke(colorRand);
  rect(initX+x*patternSize, initY + y*patternSize, patternSize, patternSize);
  redraw();
}

void readSensor(){
}

/*
*
* Esto genera patrones de cuadrados blanco y negro
*

int bw;
void draw(){
  background(230);
  for (int x = 0; x < width; x+=10) {
  for (int y = 0; y < height; y+=10) {
    bw = 255*round(random(0,1));
    noStroke();
    fill(bw);
    rect(x,y,10,10);
  }
} 
}*/
