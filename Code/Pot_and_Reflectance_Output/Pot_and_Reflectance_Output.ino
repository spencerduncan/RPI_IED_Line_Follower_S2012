int maxspeed;
int s1;
int s2;
int s3;
int s4;
int s5;
int s6;
int s7;

void setup() {
  Serial.begin(9600);
  analogReference(DEFAULT);
}

void loop() {
  maxspeed = analogRead(7);
  Serial.print("Max:\t");
  Serial.print(maxspeed);
  s1 = analogRead(5);
  Serial.print("\tS1:\t");
  Serial.print(s1);
  s2 = analogRead(4);
  Serial.print("\tS2:\t");
  Serial.print(s2);
  s3 = analogRead(3);
  Serial.print("\tS3:\t");
  Serial.print(s3);
  s4 = analogRead(2);
  Serial.print("\tS4:\t");
  Serial.print(s4);
  s5 = analogRead(1);
  Serial.print("\tS5:\t");
  Serial.print(s5);
  s6 = analogRead(0);
  Serial.print("\tS6:\t");
  Serial.print(s6);
  s7 = analogRead(6);
  Serial.print("\tS7:\t");
  Serial.println(s7);

  
}
