#include "Seeed_BME280.h"
#include <Wire.h>
#include <SoftwareSerial.h>
SoftwareSerial serial2(6,7);
BME280 bme280;

void setup()
{
  Serial.begin(115200);
  serial2.begin(115200);
  if(!bme280.init()){
    Serial.println("Device error!");
  }
}

void loop(){
  int a,b,c;
    a  = abs(bme280.getPressure());
    b = bme280.getTemperature();
    c = bme280.getHumidity()*3;
    int d = map(a,27500,32000,0,255);
    serial2.write(d);
    Serial.println(a);
}
