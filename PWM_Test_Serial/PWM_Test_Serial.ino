
void setup(){
  pinMode(3, OUTPUT);
  analogWrite(3, 150);
  //delay(10000);
  //OCR2A = 200;
  TCCR2B &= 0xF8;
  TCCR2B |=  _BV(CS20); //Sin prescaler => f = 16Mhz/256
  TCCR2A |= _BV(WGM21) | _BV(WGM20); //Fast PWM
  TIMSK2 |= _BV(TOIE2);
  //TCCR2A |= _BV(WGM20); //Phase corrected PWM
  //attachInterrupt(TIMER2_COMPA_vect_num, ISR_PWM, CHANGE);
  Serial.begin(115200);
}

char inputString[1000];         // a String to hold incoming data
boolean stringComplete = false;  // whether the string is complete

int N = 100;
int contador;
long tiempo;
//int vect[] = {128, 210, 254, 239, 172, 84, 17, 2, 46, 128};
int vect[] = {128,
   136,
   144,
   152,
   160,
   168,
   176,
   183,
   190,
   197,
   204,
   210,
   216,
   222,
   227,
   232,
   237,
   241,
   244,
   248,
   250,
   252,
   254,
   255,
   255,
   255,
   255,
   255,
   253,
   251,
   249,
   246,
   243,
   239,
   235,
   230,
   225,
   219,
   213,
   207,
   201,
   194,
   187,
   179,
   172,
   164,
   156,
   148,
   140,
   132,
   124,
   116,
   108,
   100,
    92,
    84,
    77,
    69,
    62,
    55,
    49,
    43,
    37,
    31,
    26,
    21,
    17,
    13,
    10,
     7,
     5,
     3,
     1,
     0,
     0,
     0,
     1,
     2,
     4,
     6,
     8,
    12,
    15,
    19,
    24,
    29,
    34,
    40,
    46,
    52,
    59,
    66,
    73,
    80,
    88,
    96,
   104,
   112,
   120,
   128};

int k;
int i=0;
void loop(){
  if (stringComplete) {
    k = 0;
    char* numStr = strtok(inputString, ",");
    while( numStr != 0 ){
      int num = atoi(numStr);
      vect[k] = num;
      Serial.println(num);
      k++;
      numStr = strtok(0, ",");
    }
    N=k;
    inputString[0] = 0;
    k=0;
    stringComplete = false;
  }
  
}

ISR(TIMER2_OVF_vect){
  //contador++;
  i++;
  //delayMicroseconds(50);
  if( i>N )
    i=0;
  analogWrite(3, vect[i]);
}


void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    inputString[k] = inChar;
    k++;
    // if the incoming character is a newline, set a flag so the main loop can
    // do something about it:
    if (inChar == '\n' || k==999) {
      stringComplete = true;
      k=0;
    }
  }
}
