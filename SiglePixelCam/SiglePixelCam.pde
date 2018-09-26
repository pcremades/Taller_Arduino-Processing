void setup(){
  size(800, 600);
  frameRate(2);
}

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
}
