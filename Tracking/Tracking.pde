/**
 * Brightness Tracking 
 * by Golan Levin. 
 *
 * Tracks the brightest pixel in a live video signal. 
 */


import processing.video.*;
int RThreshold = 150;
int GThreshold = 100;
int BThreshold = 100;

int[] matrixPixel = new int[100];
int[] matrixPixelX = new int[100];
int[] matrixPixelY = new int[100];
int meanX;
int meanY;

Capture video;

void setup() {
  size(640, 480);
  // Uses the default video input, see the reference if this causes an error
  video = new Capture(this, width, height);
  video.start();  
  noStroke();
  smooth();
}

void draw() {
  if (video.available()) {
    video.read();
    image(video, 0, 0, width, height); // Draw the webcam video onto the screen
    int brightestX = 0; // X-coordinate of the brightest video pixel
    int brightestY = 0; // Y-coordinate of the brightest video pixel
    float brightestValue = 0; // Brightness of the brightest video pixel
    // Search for the brightest pixel: For each row of pixels in the video image and
    // for each pixel in the yth row, compute each pixel's index in the video
    video.loadPixels();
    int index = 0;
    for (int y = 0; y < video.height; y++) {
      for (int x = 0; x < video.width; x++) {
        // Get the color stored in the pixel
        int pixelValue = video.pixels[index];
        // Determine the brightness of the pixel
        float pixelBrightness = brightness(pixelValue);
        int currR = (pixelValue >> 16) & 0xFF;
        int currG = (pixelValue >> 8) & 0xFF;
        int currB = pixelValue & 0xFF;
        if( currR > RThreshold && currG < GThreshold && currB < BThreshold ){
          meanX = meanX + x;
          meanX /= 2.0;
          meanY = meanY + y;
          meanY /= 2.0;
        }
        // If that value is brighter than any previous, then store the
        // brightness of that pixel, as well as its (x,y) location
        if (pixelBrightness > brightestValue) {
          brightestValue = pixelBrightness;
          brightestY = y;
          brightestX = x;
        }
        index++;
      }
    }
    // Draw a large, yellow circle at the brightest pixel
    fill(255, 204, 0, 128);
    ellipse(meanX, meanY, 200, 200);
    /*print(meanX);
    print(" - ");
    println(meanY);*/
  }
}