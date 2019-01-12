#define _DISABLE_TLS_
#include <SPI.h>
#include <ESP8266WiFi.h>
#include <ThingerWifi.h>

ThingerWifi thing("username", "deviceId", "pasword");

/* TIMER */
#include <SimpleTimer.h>
SimpleTimer timer;

/* DS18B20 Temperature Sensor */
#include <OneWire.h>
#include<DallasTemperature.h> 
#define ONE_WIRE_BUS 2 // DS18B20 on arduino pin2 corresponds to D4 on physical board
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature DS18B20(&oneWire);

void setup() {
  Serial.begin(115200);
  thing.add_wifi("WIFI_NAME", "password");
  DS18B20.begin();
  timer.setInterval(60*1000L, sendData);
}

String getLabel(int index)
{
  String labels[] = {
    "X", //0
    "Y", //1
    "Z", //2
  };
  return labels[index];
}

void sendData()
{
 DS18B20.requestTemperatures();
 int temperatures[10] = {}; 
 
 pson data;
 for(int i = 0; i < 3; i++){
    int temp = DS18B20.getTempCByIndex(i);
    
    if (temp > -127){
      String name = String(getLabel(i));
      data[name.c_str()] = temp;
      Serial.println(String(name) + ": " + String(temp));
    }
    
 }
 
 thing.write_bucket("testId", data);
 Serial.println("Data sent.");
}

void loop() {
 thing.handle();
 timer.run(); 
}
