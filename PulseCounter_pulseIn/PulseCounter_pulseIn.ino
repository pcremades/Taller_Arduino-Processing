#include <avr/wdt.h>
#include "ColorSensor.h"

#define PULSE_IN 5
#define PULSE_COUNT 15

#define S0 3
#define S1 4
#define S2 6
#define S3 7

ColorSensor sensor;

void setup(){
  Serial.begin(115200);
  sensor.initialize(S0, S1, S2, S3, PULSE_IN);
  sensor.setOutputFreqScale(OUTPUT_FREQSCALE_100); //No importa.
  sensor.setChannelClear();
}

void loop(){
  if( Serial.available() > 0 ){
    byte inByte = Serial.read();
    if( inByte == 'R' ){
      //Serial.println(1.0/(freq/1000000.0)*PULSE_COUNT);
      Serial.println( sensor.getFrequency(PULSE_COUNT) );
      //delay(20);
    }
  }
}


