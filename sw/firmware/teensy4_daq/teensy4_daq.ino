// teensy4_daq — stream one ADC channel as int16 over USB serial.
//
// Host: sw/vibrometer/capture.py --source teensy --port <port> --fs <SAMPLE_HZ>
//
// Protocol:
//   host -> 'S'  : emit sync 0xA5 0x5A, then stream LE int16 samples continuously
//   host -> 'X'  : stop streaming
// Samples are (raw 12-bit ADC - 2048) << 4, i.e. signed and left-justified.

#include <Arduino.h>
#include <IntervalTimer.h>

static const int      ADC_PIN    = A0;
static const uint32_t SAMPLE_HZ  = 250000;   // keep in sync with capture.py --fs
static const size_t   RINGSIZE   = 4096;     // power of two

volatile int16_t ring[RINGSIZE];
volatile size_t  head = 0, tail = 0;
volatile bool    streaming = false;
IntervalTimer    sampler;

void onSample() {
  int raw = analogRead(ADC_PIN);            // 12-bit (analogReadResolution(12) below)
  int16_t s = (int16_t)((raw - 2048) << 4);
  size_t next = (head + 1) & (RINGSIZE - 1);
  if (next != tail) {                       // drop on overrun rather than block
    ring[head] = s;
    head = next;
  }
}

void setup() {
  Serial.begin(2000000);
  analogReadResolution(12);
  analogReadAveraging(1);
  pinMode(ADC_PIN, INPUT);
  sampler.begin(onSample, 1000000.0 / SAMPLE_HZ);
}

void loop() {
  if (Serial.available()) {
    char c = Serial.read();
    if (c == 'S') {
      head = tail = 0;
      streaming = true;
      uint8_t sync[2] = {0xA5, 0x5A};
      Serial.write(sync, 2);
    } else if (c == 'X') {
      streaming = false;
    }
  }

  if (streaming) {
    // drain the ring in chunks
    uint8_t buf[512];
    size_t n = 0;
    noInterrupts();
    while (tail != head && n < sizeof(buf) - 1) {
      int16_t s = ring[tail];
      tail = (tail + 1) & (RINGSIZE - 1);
      buf[n++] = (uint8_t)(s & 0xFF);
      buf[n++] = (uint8_t)((s >> 8) & 0xFF);
    }
    interrupts();
    if (n) Serial.write(buf, n);
  }
}
