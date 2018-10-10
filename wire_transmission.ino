char dataID1 = 'A';
char dataID2 = 'B';
//#include <SoftwareSerial.h>

//Tx to 6, Rx to 7
//Tx to 9, Rx to 10

void setup() {
  Serial.begin(115200);
  Serial1.begin(115200);
}

void loop() {
  if(Serial.available()) {
    int sensorValue1 = Serial.read();
    Serial.print('A');
    Serial.println(sensorValue1);
//    sendDataToProcessing(dataID1, sensorValue1);
  }
  if(Serial1.available()) {
    int sensorValue2 = Serial1.read();
    Serial1.print('B');
    Serial1.println(sensorValue2);
//    sendDataToProcessing(dataID2, sensorValue2);
  }
  
  delay(2);
}

//void sendDataToProcessing(char symbol, float data){
//  Serial.print(symbol);
//  Serial.println(data);
//}
