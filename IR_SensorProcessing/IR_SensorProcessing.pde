import processing.serial.*;

Serial puerto;
String inString;
int analogVal;
int N = 3;
float[] x = new float[N+1];
float[] y = new float[N+1];
float[] a={-2.219169, 1.715118, -0.453546};
float[] b={0.005300, 0.015901, 0.015901, 0.00530};
int tiempo;
int i=0;

void setup(){
  size( 800, 600);
  puerto = new Serial(this, "/dev/ttyACM0", 115200);
  puerto.bufferUntil('\n');
}

void draw(){
  if( inString != null ){
    //println(inString.trim());
    try{
    analogVal = Integer.parseInt(inString.trim());
    println(y[0]);
    for( int j=0; j<N; j++ ){
     x[j] =  x[j+1];
     y[j] =  y[j+1];
    }
    x[N] = analogVal;
    y[N] = b[0]*x[N] + b[1]*x[N-1] + b[2]*x[N-2] + b[3]*x[N-3] - a[0]*y[N-1] - a[1]*y[N-2] - a[2]*y[N-3];
    //println(millis() - tiempo + "   " + y[0]);
    tiempo = millis();
    inString="";
    fill(0);
    ellipse( i, height*2/3 - y[N]/5, 5, 5);
    //ellipse( i, height*2/3 - analogVal/5, 5, 5);
    i++;
    if( i>width){
      i=0;
      background(250);
    }
    }
    catch( Exception e){
    }
  }
}

void serialEvent(Serial p){
  inString = p.readString();
}