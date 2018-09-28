#include <avr/wdt.h>

long tiempo=0;
long freq=0;

void setup(){
  pinMode( 5, INPUT_PULLUP);
  cli();
  //Set the watchdog
  
  TCCR1A &= 0x0;  //CTC mode
  //TCCR2B &= !(0x0F); //Clear prescaler settings
  TCCR1B |= (1 << WGM12) | (1 << CS12) | (1 << CS11) | (1 << CS10);
  OCR1A = 249;  //Contar 250 pulsos.
  TIMSK1 |= (1 << OCIE1A); // Enable CTC interrupt
  
  sei();
  
  Serial.begin(115200);
  Serial.println(TCCR1B, BIN);
}

void loop(){
  Serial.println(1.0/(freq/1000000.0)*250);
  delay(2000);
}

ISR(TIMER1_COMPA_vect){
  tiempo = micros() - tiempo;
  freq = tiempo;
  tiempo = micros();
}
