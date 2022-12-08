/*
   Copyright 2017 Pablo Cremades
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

**************************************************************************************
* Autor: Pablo Cremades
* e-mail: pablocremades@gmail.com
* Descripción: Este programa muestra cómo configurar un timer para tareas periódicas
*   y el uso del Watch Dog.
*
* Change Log:
* -
*/
#Include <avr/wdt.h>

int count=0;
char flag=0;

void setup(){
  cli();
  //Set the watchdog
  WDTCSR |= (1<<WDCE) | (1<<WDE);
  WDTCSR = (1<<WDE) | (1<<WDP3);  //4 segundos

  // Set Timer2
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

/* Esta rutina se ejecuta cada vez que el Timer interrumpe (cada 1ms).
   El contador hasta 1000 permite programar tareas que se ejecuten en
   loop() cada un intervalo de tiempo determinado, 1s en este caso.
 */
ISR(TIMER2_COMPA_vect){
  count++;
  //TCNT2   = 6;
  if(count == 1000){
    count = 0;
    flag = 0;
  }
}
