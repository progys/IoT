#define _DISABLE_TLS_
#include <SPI.h>
#include <ESP8266WiFi.h>
#include <ThingerWifi.h>
#include "arduino_secrets.h"

ThingerWifi thing(USERNAME, DEVICE_ID, DEVICE_CREDENTIAL);

/* TIMER */
#include <SimpleTimer.h>
SimpleTimer timer;

/* DS18B20 Temperature Sensor */
#include <OneWire.h>
#include <DallasTemperature.h>
#define ONE_WIRE_BUS 2 // DS18B20 on arduino pin2 corresponds to D4 on physical board
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature DS18B20(&oneWire);

String getLabel(int index)
{
  switch (index)
  {
  case 0:
    return "backa 1";
    break;
  case 1:
    return "backa 2";
    break;
  case 2:
    return "backa 3";
    break;
  case 3:
    return "backa 4";
    break;
  case 4:
    return "boileris";
    break;
  case 5:
    return "laukas";
    break;
  case 6:
    return "namas";
    break;
  default:
    return "rez1";
  };
}

void sendData()
{
  DS18B20.requestTemperatures();

  pson data;
  for (int i = 0; i < 7; i++)
  {
    int temp = DS18B20.getTempCByIndex(i);

    if (temp > -127)
    {
      String name = String(getLabel(i));
      data[name.c_str()] = temp;
      Serial.println(String(name) + ": " + String(temp));
    }
  }

  thing.write_bucket(DEVICE_ID, data);
  Serial.println("Data sent.");
}

void setup()
{
  Serial.begin(115200);
  thing.add_wifi(WIFI_NAME, WIFI_PASSWORD);
  DS18B20.begin();
  timer.setInterval(60 * 1000L, sendData);
}

void loop()
{
  thing.handle();
  timer.run();
}
