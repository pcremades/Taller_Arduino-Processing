#include <avr/wdt.h>

#define PULSE_IN 5
#define PULSE_COUNT 250

#define S0 3
#define S1 4
#define S2 6
#define S3 7

long tiempo=0;
long freq=0;

void setup(){
  configTCS();
  setTMR1();
  Serial.begin(115200);
  Serial.println(TCCR1B, BIN);
}

void loop(){
  if( Serial.available() > 0 ){
    byte inByte = Serial.read();
    if( inByte == 'R' ){
      Serial.println(1.0/(freq/1000000.0)*PULSE_COUNT);
      //delay(20);
    }
  }
}

ISR(TIMER1_COMPA_vect){
  tiempo = micros() - tiempo;
    //Serial.println(tiempo);
    //Serial.println(1.0/(freq/1000000.0)*PULSE_COUNT);
  freq = tiempo;
  tiempo = micros();
}

void setTMR1(){
  pinMode( PULSE_IN, INPUT_PULLUP);
  cli();  
  TCCR1A &= 0x0;  //CTC mode
  //TCCR2B &= !(0x0F); //Clear prescaler settings
  TCCR1B |= (1 << WGM12) | (1 << CS12) | (1 << CS11) | (1 << CS10);
  OCR1A = PULSE_COUNT - 1;  //Contar 250 pulsos.
  TIMSK1 |= (1 << OCIE1A); // Enable CTC interrupt
  sei();
}

void configTCS(){
  pinMode(S0, OUTPUT); digitalWrite(S0, HIGH);
  pinMode(S1, OUTPUT); digitalWrite(S1, HIGH);
  pinMode(S2, OUTPUT); digitalWrite(S2, HIGH);
  pinMode(S3, OUTPUT); digitalWrite(S3, LOW);
}

