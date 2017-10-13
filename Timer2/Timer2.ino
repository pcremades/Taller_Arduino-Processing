#include <avr/wdt.h>

int count=0;
char flag=0;

void setup(){
  cli();
  //Set the watchdog
  WDTCSR |= (1<<WDCE) | (1<<WDE);
  WDTCSR = (1<<WDE) | (1<<WDP3);  //4 segundos
  
  TCCR2A &= 0x0;  //CTC mode
  TCCR2A |= 0x2;
  TCCR2B &= !(0x0F); //Clear prescaler settings
  TCCR2B |= 0x4; //Fcpu/8
  OCR2A = 249;  //Contar 250 pulsos.
  TIMSK2 |= (1 << OCIE2A); // Enable CTC interrupt
  
  sei();
  
  Serial.begin(115200);
}

void loop(){
  if( count == 0 && flag == 0){
        Serial.println(millis());
        flag =1;
        wdt_reset();
  }
}

ISR(TIMER2_COMPA_vect){
  count++;
  //TCNT2   = 6;
  if(count == 1000){
    count = 0;
    flag = 0;
  }
}
