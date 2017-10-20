void setup(){
  Serial.begin(115200);
  analogReference(EXTERNAL);
}

void loop(){
  Serial.println(analogRead(A0));
  delay(50);
}
