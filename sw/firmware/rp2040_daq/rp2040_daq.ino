// rp2040_daq — stream one ADC channel as int16 over USB serial (arduino-pico core).
//
// Host: sw/vibrometer/capture.py --source teensy --port <port> --fs <SAMPLE_HZ>
// (same wire protocol as teensy4_daq; the host path is shared.)
//
//   host -> 'S' : emit sync 0xA5 0x5A, then stream LE int16 samples
//   host -> 'X' : stop
// Sample = (raw 12-bit ADC - 2048) << 4.

#include <Arduino.h>

static const int      ADC_PIN   = A0;
static const uint32_t SAMPLE_HZ = 200000;   // keep in sync with capture.py --fs

bool     streaming = false;
uint32_t next_us   = 0;
const uint32_t period_us = 1000000UL / SAMPLE_HZ;

void setup() {
  Serial.begin(2000000);
  analogReadResolution(12);
  next_us = micros();
}

void loop() {
  if (Serial.available()) {
    char c = Serial.read();
    if (c == 'S') {
      streaming = true;
      next_us = micros();
      uint8_t sync[2] = {0xA5, 0x5A};
      Serial.write(sync, 2);
    } else if (c == 'X') {
      streaming = false;
    }
  }

  if (streaming) {
    uint32_t now = micros();
    if ((int32_t)(now - next_us) >= 0) {
      next_us += period_us;
      int raw = analogRead(ADC_PIN);
      int16_t s = (int16_t)((raw - 2048) << 4);
      uint8_t b[2] = {(uint8_t)(s & 0xFF), (uint8_t)((s >> 8) & 0xFF)};
      Serial.write(b, 2);
    }
  }
}
