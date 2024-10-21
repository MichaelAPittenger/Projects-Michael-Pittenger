//libaries and definitions
// Oximeter: https://github.com/sparkfun/SparkFun_MAX3010x_Sensor_Library/tree/master/examples
#include "heartRate.h"
#include "spo2_algorithm.h"
//haptic motor: https://github.com/adafruit/Adafruit_DRV2605_Library
#include <Wire.h>
#include "Adafruit_DRV2605.h"
#include <Stepper.h>
#include "MAX30105.h" // Include MAX30105 sensor library
#include "spo2_algorithm.h" // Include SpO2 calculation algorithm
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define STEPS 2038 // the number of steps in one revolution of your motor (28BYJ-48)
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

#define OLED_RESET -1  // Reset pin is not used with I2C
 
MAX30105 particleSensor; // Create an instance of the MAX30105 class
Stepper stepper(STEPS, 8, 10, 9, 11);

// Adjust buffer size based on the microcontroller's memory capacity
#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega168__)
uint16_t irBuffer[100]; // Buffer for IR data (16-bit for memory-limited devices)
uint16_t redBuffer[100]; // Buffer for red LED data
#else
uint32_t irBuffer[100]; // Buffer for IR data (32-bit for devices with more memory)
uint32_t redBuffer[100]; // Buffer for red LED data
#endif
 
int32_t bufferLength = 100; // Length of data buffer
int32_t spo2; // Variable to store calculated SpO2 value
int8_t validSPO2; // Flag indicating if SpO2 calculation is valid
int32_t heartRate; // Variable to store calculated heart rate
int8_t validHeartRate; // Flag indicating if heart rate calculation is valid
 
byte pulseLED = 11; // LED pin for pulse indication (must support PWM)
byte readLED = 13; // LED pin to indicate data read operation
 
//pins # inputs & # outputs
//inputs
const int buttonPin1 = 2;
const int buttonPin2 = 29;
//outputs
const int LEDs = 5;
const int blue = 36;
const int green = 37;
const int yellow = 42;
const int red = 39;

//variables
//swtich between modes button
int buttonState1 = 0;
int lastButtonState1 = 0;
volatile int mode = 0;
volatile bool motorActivated = false;
volatile bool modeChanged = false;
uint8_t effect = 89;

Adafruit_DRV2605 drv;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

//initialize functions
void checkVitals(bool var);

void setup() { 
  Serial.begin(115200);
  // put your setup code here, to run once:
  //inputs
  pinMode(buttonPin1, INPUT_PULLUP); // Set buttonPin1 as input with pull-up resistor
  attachInterrupt(digitalPinToInterrupt(buttonPin1), toggleMode, CHANGE); // Attach interrupt to buttonPin1
  //outputs
  pinMode(LEDs, OUTPUT);
  pinMode(blue, OUTPUT);
  pinMode(green, OUTPUT);
  pinMode(yellow, OUTPUT);
  pinMode(red, OUTPUT);
  
  pinMode(pulseLED, OUTPUT); // Set pulseLED as output
  pinMode(readLED, OUTPUT); // Set readLED as output


  if (! drv.begin()) {
    Serial.println("Could not find DRV2605");
    while (1) delay(10);
  }
 
  drv.selectLibrary(1);
  
  // I2C trigger by sending 'go' command 
  // default, internal trigger when sending GO command
  drv.setMode(DRV2605_MODE_INTTRIG); 

    // Initialize the display
  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {  // Address 0x3C for 128x64
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }
  
  // Clear the buffer
  display.clearDisplay();
  
  // Set text size and color
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  
  // Display initial text
  display.setCursor(0, 0);
  display.println(F("Power on!"));
  
  // Display on OLED
  display.display();

  //standby
  runMode(0);
}

void loop() {
  runMode(mode);
  if (modeChanged) {
    mode = (mode + 1) % 4; // Toggle mode
    modeChanged = false; // Reset flag
    runMode(mode); // Call runMode() to execute the new mode
  }
  // Other loop code here...
}

void toggleMode() {
  static unsigned long lastInterruptTime = 0;
  unsigned long interruptTime = millis();
  // If interrupts come faster than 50ms, assume it's a bounce and ignore
  if (interruptTime - lastInterruptTime > 50) {
    modeChanged = true; // Set flag to indicate mode change
  }
  lastInterruptTime = interruptTime; // Update last interrupt time
}

//modes
void runMode(int mode) {
  display.clearDisplay();
  switch(mode){
    case 0:
      //standby mode
      Serial.print("Standy Mode");
      Serial.print('\n');
      display.setCursor(0, 0);
      display.print("STANDBY MODE:        Press button to begin");
      display.display();
      digitalWrite(blue, HIGH);
      digitalWrite(green, LOW);
      digitalWrite(yellow, LOW);
      digitalWrite(red, LOW);
      standby();
      break;
    case 1:
      //vital read mode
      Serial.print("Reading Vitals");
      Serial.print('\n');
      display.setCursor(0, 0);
      display.print("READING VITALS:      Hold finger to sensor");
      display.display();
      digitalWrite(blue, HIGH);
      digitalWrite(blue, LOW);
      digitalWrite(green, HIGH);
      digitalWrite(yellow, LOW);
      digitalWrite(red, LOW);
      readVitals();
      break;
    case 2:
      //test mode
      //emergency mode
      Serial.print("Check on user");
      Serial.print('\n');
      display.setCursor(0, 0);
      display.print("CHECK ON USER:       Press button if safe");
      display.display();
      digitalWrite(blue, LOW);
      digitalWrite(green, LOW);
      digitalWrite(yellow, HIGH);
      digitalWrite(red, LOW);
      checkUser();
      break;
    case 3:
      
      Serial.print("HELP");
      Serial.print('\n');
      display.setCursor(0, 0);
      display.print("DROWNING!!!");
      display.display();
      digitalWrite(blue, LOW);
      digitalWrite(green, LOW);
      digitalWrite(yellow, LOW);
      digitalWrite(red, HIGH);
      delay(100);
      digitalWrite(blue, LOW);
      digitalWrite(green, LOW);
      digitalWrite(yellow, HIGH);
      digitalWrite(red, LOW);
      delay(50);
      //emergency mode
      emergencyResponse();
      break;
  }
}
//Standby
void standby() {
  //turn off motor()
  motorInput(false);
  //turn off LEDs
  LEDInput(false);
  //turn off haptic
  hapticInput(false);
  //turn off speaker
  speakerInput(false);
  return;
}

//Vital reading mode
void readVitals(){
  //check vitals
  checkVitals(true);
}


//check on user

//Compare data
bool isDataCorrect(int avgBPM, int avgO) {
  //compare to certain values
}

void checkUser() {
  hapticInput(true);
}

void emergencyResponse() {
  
  //activate motor
  motorInput(true);
  
  
  //activate LEDs
  LEDInput(true);
  
  
  //activate haptic
  //hapticInput(true);
 

  //activate speaker
  speakerInput(true);
  
  
  Serial.println("Emergency response completed"); // Debug statement
  return;
}

void checkVitals(bool var) {
  // Initialize MAX30105 sensor
  if (var) {
    if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
      Serial.println(F("MAX30105 not found. Check wiring/power."));
      while (1); // Halt execution if sensor not found
    }
 
    // Sensor configuration settings
    byte ledBrightness = 60; // LED brightness (0-255)
    byte sampleAverage = 4; // Averaging (1, 2, 4, 8, 16, 32)
    byte ledMode = 2; // LED mode (1=Red, 2=Red+IR, 3=Red+IR+Green)
    byte sampleRate = 100; // Sampling rate (50, 100, 200, 400, 800, 1000, 1600, 3200)
    int pulseWidth = 411; // Pulse width (69, 118, 215, 411)
    int adcRange = 4096; // ADC range (2048, 4096, 8192, 16384)
   
    // Apply configuration settings to the sensor
    particleSensor.setup(ledBrightness, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange);
    
    // Collect 100 samples and output raw red and IR data
    for (byte i = 0; i < bufferLength; i++) {
      while (!particleSensor.available()) particleSensor.check(); // Wait for new data
   
      redBuffer[i] = particleSensor.getRed(); // Store red LED data
      irBuffer[i] = particleSensor.getIR(); // Store IR data
      particleSensor.nextSample(); // Move to next sample
   
      Serial.print(F("red="));
      Serial.print(redBuffer[i], DEC);
      Serial.print(F(", ir="));
      Serial.println(irBuffer[i], DEC);
    }
 
    // Calculate heart rate and SpO2 from the first 100 samples
    maxim_heart_rate_and_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2, &heartRate, &validHeartRate);
 
    // Display heart rate and SpO2 values on the OLED display
    display.clearDisplay();
    display.setCursor(0, 0);
    display.print("Heart Rate: ");
    display.println(heartRate);
    display.print("SpO2: ");
    display.println(spo2);
    display.display();
    
    // Continuously update heart rate and SpO2 values with new samples
    while (1) {
      // Shift the last 75 samples to the beginning and fill the remaining with new data
      for (byte i = 25; i < 100; i++) {
        redBuffer[i - 25] = redBuffer[i];
        irBuffer[i - 25] = irBuffer[i];
      }
   
      // Collect new samples to refill the buffer
      for (byte i = 75; i < 100; i++) {
        while (!particleSensor.available()) particleSensor.check(); // Wait for new data
   
        digitalWrite(readLED, !digitalRead(readLED)); // Blink LED with each data read
   
        redBuffer[i] = particleSensor.getRed(); // Store new red data
        irBuffer[i] = particleSensor.getIR(); // Store new IR data
        particleSensor.nextSample(); // Move to next sample
   
        // Output raw data and calculated heart rate/SpO2 values
        Serial.print(F("red="));
        Serial.print(redBuffer[i], DEC);
        Serial.print(F(", ir="));
        Serial.print(irBuffer[i], DEC);
        Serial.print(F(", HR="));
        Serial.print(heartRate, DEC);
        Serial.print(F(", HRvalid="));
        Serial.print(validHeartRate, DEC);
        Serial.print(F(", SPO2="));
        Serial.print(spo2, DEC);
        Serial.print(F(", SPO2Valid="));
        Serial.println(validSPO2, DEC);
      }
   
      // Recalculate heart rate and SpO2 with the updated buffer
      maxim_heart_rate_and_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2, &heartRate, &validHeartRate);
  
      // Update OLED display with new heart rate and SpO2 values
      display.clearDisplay();
      display.setCursor(0, 0);
      display.print("Heart Rate: ");
      display.println(heartRate);
      display.print("SpO2: ");
      display.println(spo2);
      display.display();
  
      if (heartRate <= 0) {
        mode = 2;
        break;
      }
    }
  }
}
  
//motor to inflate bag
void motorInput(bool var) {
  if (var && !motorActivated) {
    stepper.setSpeed(11); // Set speed to 11 RPM
    stepper.step(900); // Move 900 steps
    Serial.println("Co2 Cartridge engaged bag should inflate."); // Testing statement
    motorActivated = true; // Set the flag to true to indicate the motor has been activated
  } else {
    stepper.step(0); // Stop the motor
    Serial.println("Motor mode is false. Motor movement stopped."); // Debug statement
  }
}

//accelerometer

//oximeter

//LCD Screen
void LCDDisplay() {
  
}

//getButton
int getButton() {
  //return int
}

//LEDs
void LEDInput(bool Mode) {
  if (Mode == true) {
    //LEDs on
  }
  else{
    //LEDs off
  }
}

//Speaker
void speakerInput(bool Mode) {
  if (Mode == true) {
    //speaker on
  }
  else{
    //speaker off
  }
}

//haptic motor
void hapticInput(bool var) {
  int counter = 0;
  if (var == true) {
    while(counter < 10){
        Serial.print("Effect #"); Serial.println(effect);
  
        // set the effect to play
        drv.setWaveform(0, effect);  // play effect 
        drv.setWaveform(1, 0);       // end waveform
      
        // play the effect!
        drv.go();
    
      // wait a bit
      counter++;
      
      buttonState1 = digitalRead(buttonPin1);
      if(buttonState1 == HIGH){
        mode = 0;
        break;
      }
      mode = 2;
      delay(1000);
    }
    delay(1000);
  }

  else{
    //haptic off
  }
  
}
