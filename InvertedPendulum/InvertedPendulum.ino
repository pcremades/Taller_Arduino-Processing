/****************************************
 * Controlled Inverted Pendulum         *
 *                                      *
 * Josh Vazquez 2013                    *
 *                                      *
 * Based on Arduino Starter Kit         *
 *  Project 10: Zoetrope                *
 * PID library by Brett Beauregard      *
 *                                      *
 ****************************************/

#include <PID_v1.h>

// PHYSICAL PINS *********************************************************************
// these are used to tell the IC which way to turn the motor
const int directionPin1 = 12;
const int directionPin2 = 11;

// where to send 0-255 signal for motor voltage 0-100%
const int pwmPin = 9;

// rotary encoder attachment
//const int encoderPin = A0;

// CONSTANTS *************************************************************************
// encoder angle at top of arc
const int desiredAngle = 0;

// VARIABLES *************************************************************************
int motorDirection = 1;

// encoder sends raw values 0-1023
int encoderPosition = 0;
int CartPosition = 0;

// degrees 0-359
float encoderAngle = 0;

// -179 <= relativeAngle <= 180: pendulum angle difference from top of arc
float relativeAngle = 0;

// difference between real angle and desired angle
float error = 0;

// PID VARIABLES *********************************************************************
double pidSetpoint, pidInput, pidOutput;
double realOutput;
double linSetpoint, linInput, linOutput;
double linRealOutput;

// create the PID controller
//PID rotPID(&pidInput, &pidOutput, &pidSetpoint, 40, 0, 0, DIRECT); // standard tuning
//PID rotPID(&pidInput, &pidOutput, &pidSetpoint, 15, 25, 5, DIRECT); // standard tuning
//PID rotPID(&pidInput, &pidOutput, &pidSetpoint, 18, 32, 0.16, DIRECT); // standard tuning
//PID rotPID(&pidInput, &pidOutput, &pidSetpoint, 15, 12, 0.16, DIRECT); // standard tuning
//PID rotPID(&pidInput, &pidOutput, &pidSetpoint, 11, 50, 0.2, DIRECT); // standard tuning
PID rotPID(&pidInput, &pidOutput, &pidSetpoint, 11, 40, 0.2, DIRECT); // standard tuning
PID linPID(&linInput, &pidSetpoint, &linSetpoint, 0.0015, 0.0002, 0.0006, DIRECT);
//PID rotPID(&pidInput, &pidOutput, &pidSetpoint, 4, 4, 0, DIRECT); // debug tuning

/*
// frontend
 double Setpoint = desiredAngle;
 double Input = encoderPin;
 double Output = pwmPin;
 
 unsigned long serialTime;
 */

// reverse the motor direction
void changeDirection() {
  if (motorDirection == 1) {
    digitalWrite(directionPin1, HIGH);
    digitalWrite(directionPin2, LOW);
  }
  else {
    digitalWrite(directionPin1, LOW);
    digitalWrite(directionPin2, HIGH);
  }
}

void setup() {
  // specify output pins being used
  pinMode(directionPin1, OUTPUT);
  pinMode(directionPin2, OUTPUT);
  pinMode(pwmPin, OUTPUT);
  pinMode( 2, INPUT_PULLUP );
  pinMode( 4, INPUT_PULLUP );
  pinMode( 3, INPUT_PULLUP );
  pinMode( 5, INPUT_PULLUP );
  attachInterrupt( 0, ISR_Pend, CHANGE);
  attachInterrupt( 1, ISR_Cart, CHANGE);
  pinMode( 8, INPUT_PULLUP);  

  // start with 0 motor power
  digitalWrite(pwmPin, LOW);

  // PID variables
  pidInput = 0;
  pidSetpoint = desiredAngle;

  // turn PID on
  rotPID.SetMode(AUTOMATIC);
  linPID.SetMode(AUTOMATIC);

  /* limits: fixes "0" returned for angles 0-180. Uses -128.0~128.0 so that the
   *  values can be boosted by +/-127 to give a motor output range of -255~-127,
   *  0, and 127~255. This is because the lower half of 0-255 gives too little
   *  voltage to the motor for it to spin. */
  rotPID.SetOutputLimits(-128.0, 128.0);
  linPID.SetOutputLimits(-128.0, 128.0);

  // get ready to log data to computer
  Serial.begin(115200);

}

int thetaCero;
int inByte;
boolean start = true;
double lastTime;

int CartCero;

void inicio(){
  motorDirection = 1;
  changeDirection();
  analogWrite(pwmPin, 150);
  Serial.println("Hasta el fin de carrera");
  while( digitalRead(8) == 1 );
  //Serial.println("llegamos a cero");
  CartPosition = 0;
  motorDirection = 0;
  changeDirection();
  analogWrite(pwmPin, 150);
  while( CartPosition < 1700 ){
    Serial.println(CartPosition);
  }
  analogWrite(pwmPin, 0);
  delay( 5000 );
  encoderPosition=0;
  CartCero = CartPosition;
  CartPosition = 0;
  linSetpoint = 0;
  start = false; 
}

void loop() {
  if( start ){
    inicio();
  }

  delay(1);
  if( Serial.available()>0 ){
    inByte = Serial.read();
    Serial.flush();
  }
  if( inByte == 's'){
    encoderPosition=0;
    inByte = 0;
  }

  encoderAngle = encoderPosition*360.0/1500.0;

  // with 0 degrees being the top and increasing clockwise, the left half of the
  //  rotation range is considered to be -179~-1 instead of 181~359.
  if (encoderAngle > 180) {
    relativeAngle = encoderAngle - 360;
  }
  else {
    relativeAngle = encoderAngle;
  }

  // difference from desiredAngle, doesn't account for desired angles other than 0
  error = relativeAngle;
  
  linInput = double(CartPosition);
  linPID.Compute();

  // do the PID magic
  pidInput = error;
  //pidSetpoint = -pidSetpoint;
  rotPID.Compute();

  if (pidOutput < 0) {
    motorDirection = 0;
    changeDirection();
  }
  else {
    motorDirection = 1;
    changeDirection();
  }

  // minimum motor power is 50%
  if (pidOutput == 0) {
    realOutput = 0;
  }
  else if (pidOutput > 0) {
    realOutput = pidOutput + 127;
  }
  else if (pidOutput < 0) {
    realOutput = pidOutput - 127;
  }

  // if the pendulum is too far off of vertical to recover, turn off the PID and motor
  if (error > 45 || error < -45 || digitalRead(8) == 0 || CartPosition > 1500) {
    //Serial.print("-- Angle out of bounds -- ");
    rotPID.SetMode(MANUAL);
    analogWrite(pwmPin, 0);
    pidOutput = 0;
    realOutput = 0;
  }
  else {
    rotPID.SetMode(AUTOMATIC);
    // in bounds
    //Serial.print("-- MOTOR ACTIVE, write ");
    //Serial.print(realOutput);
    //Serial.print(" --");
    analogWrite(pwmPin, abs(realOutput));
  }

  /*  
   // frontend
   if (millis()>serialTime) {
   SerialReceive();
   SerialSend();
   serialTime+=500;
   }
   */


  // debug logging
  //Serial.print("Relative angle: ");
  if( millis() - lastTime > 30){
    Serial.print(relativeAngle, 2);
    Serial.print("   ");
    Serial.print(linInput);
    Serial.print("   ");
    Serial.println(pidSetpoint);
    lastTime = millis();
  }
  //Serial.print(" -- PID output: ");
  //Serial.println(pidOutput);
  //Serial.print(" -- proportional: ");
  //Serial.print(-- integral: ## -- derivative: ##")
  //delay(10);

}

void ISR_Pend(){
  if( digitalRead(4) == digitalRead(2) )
    encoderPosition++;
  else
    encoderPosition--;
}

void ISR_Cart(){
  if( digitalRead(3) == digitalRead(5) )
    CartPosition++;
  else
    CartPosition--;
}




