// Michael Pittenger

// EE 782 Project Test Code

#include <Adafruit_ISM330DHCX.h>

Adafruit_ISM330DHCX ism330dhcx;


// IMU variables
float accx;
float accy;
float accz;

float gyrx;
float gyry;
float gyrz;

unsigned long startTime;

void setup(void) {
  Serial.begin(115200);
  while (!Serial)
    delay(10); // will pause Zero, Leonardo, etc until serial console opens

  Serial.println("Adafruit ISM330DHCX test!");

  if (!ism330dhcx.begin_I2C()) {
    Serial.println("Failed to find ISM330DHCX chip");
    while (1) {
      delay(10);
    }
  }

  Serial.println("ISM330DHCX Found!");

  // Set accelerometer and gyro ranges and data rates
  Serial.print("Accelerometer range set to: ");
  switch (ism330dhcx.getAccelRange()) {
    case LSM6DS_ACCEL_RANGE_2_G:
      Serial.println("+-2G");
      break;
    case LSM6DS_ACCEL_RANGE_4_G:
      Serial.println("+-4G");
      break;
    case LSM6DS_ACCEL_RANGE_8_G:
      Serial.println("+-8G");
      break;
    case LSM6DS_ACCEL_RANGE_16_G:
      Serial.println("+-16G");
      break;
  }

  Serial.print("Gyro range set to: ");
  switch (ism330dhcx.getGyroRange()) {
    case LSM6DS_GYRO_RANGE_125_DPS:
      Serial.println("125 degrees/s");
      break;
    case LSM6DS_GYRO_RANGE_250_DPS:
      Serial.println("250 degrees/s");
      break;
    case LSM6DS_GYRO_RANGE_500_DPS:
      Serial.println("500 degrees/s");
      break;
    case LSM6DS_GYRO_RANGE_1000_DPS:
      Serial.println("1000 degrees/s");
      break;
    case LSM6DS_GYRO_RANGE_2000_DPS:
      Serial.println("2000 degrees/s");
      break;
    case ISM330DHCX_GYRO_RANGE_4000_DPS:
      Serial.println("4000 degrees/s");
      break;
  }

  // Initialize accelerometer and gyro data rate
  Serial.print("Accelerometer data rate set to: ");
  switch (ism330dhcx.getAccelDataRate()) {
    case LSM6DS_RATE_SHUTDOWN:
      Serial.println("0 Hz");
      break;
    case LSM6DS_RATE_12_5_HZ:
      Serial.println("12.5 Hz");
      break;
    case LSM6DS_RATE_26_HZ:
      Serial.println("26 Hz");
      break;
    case LSM6DS_RATE_52_HZ:
      Serial.println("52 Hz");
      break;
    case LSM6DS_RATE_104_HZ:
      Serial.println("104 Hz");
      break;
    case LSM6DS_RATE_208_HZ:
      Serial.println("208 Hz");
      break;
    case LSM6DS_RATE_416_HZ:
      Serial.println("416 Hz");
      break;
    case LSM6DS_RATE_833_HZ:
      Serial.println("833 Hz");
      break;
    case LSM6DS_RATE_1_66K_HZ:
      Serial.println("1.66 KHz");
      break;
    case LSM6DS_RATE_3_33K_HZ:
      Serial.println("3.33 KHz");
      break;
    case LSM6DS_RATE_6_66K_HZ:
      Serial.println("6.66 KHz");
      break;
  }

  Serial.print("Gyro data rate set to: ");
  switch (ism330dhcx.getGyroDataRate()) {
    case LSM6DS_RATE_SHUTDOWN:
      Serial.println("0 Hz");
      break;
    case LSM6DS_RATE_12_5_HZ:
      Serial.println("12.5 Hz");
      break;
    case LSM6DS_RATE_26_HZ:
      Serial.println("26 Hz");
      break;
    case LSM6DS_RATE_52_HZ:
      Serial.println("52 Hz");
      break;
    case LSM6DS_RATE_104_HZ:
      Serial.println("104 Hz");
      break;
    case LSM6DS_RATE_208_HZ:
      Serial.println("208 Hz");
      break;
    case LSM6DS_RATE_416_HZ:
      Serial.println("416 Hz");
      break;
    case LSM6DS_RATE_833_HZ:
      Serial.println("833 Hz");
      break;
    case LSM6DS_RATE_1_66K_HZ:
      Serial.println("1.66 KHz");
      break;
    case LSM6DS_RATE_3_33K_HZ:
      Serial.println("3.33 KHz");
      break;
    case LSM6DS_RATE_6_66K_HZ:
      Serial.println("6.66 KHz");
      break;
  }

  ism330dhcx.configInt1(false, false, true); // accelerometer DRDY on INT1
  ism330dhcx.configInt2(false, true, false); // gyro DRDY on INT2

  // CSV header for data logging
  Serial.println("Time (ms), AccX, AccY, AccZ, GyroX, GyroY, GyroZ");

  // Start time for 20 seconds
  startTime = millis();
}

void loop() {
  // Check if 20 seconds have passed
  // if (millis() - startTime >= 20000) {
  //   Serial.println("20 seconds have passed. Stopping.");
  //   while(1);  // Stop the program by entering an infinite loop
  // }

  // Get a new normalized sensor event
  sensors_event_t accel;
  sensors_event_t gyro;
  sensors_event_t temp;
  ism330dhcx.getEvent(&accel, &gyro, &temp);

  // Update sensor values
  accx = accel.acceleration.x;
  accy = accel.acceleration.y;
  accz = accel.acceleration.z;
  gyrx = gyro.gyro.x;
  gyry = gyro.gyro.y;
  gyrz = gyro.gyro.z;

  float theta_pitch = atan2(accel.acceleration.z, accel.acceleration.x);
  float theta_roll = atan2(accel.acceleration.z, accel.acceleration.y);

  // Log the data in CSV format with increased precision (6 decimal places)
  unsigned long currentTime = millis();  // Get time in milliseconds
  // Serial.print(currentTime);              // Print time (in ms)
  // Serial.print(",");                      // Separator
  Serial.print("Orientation: ");
  Serial.print(0);
  Serial.print(", ");
  Serial.print(-(theta_roll*57.2957795-90), 6);
  Serial.print(", ");
  Serial.print(-(theta_pitch*57.2957795-90), 6); // multply by 57.295779513082320876798154814105 for degrees
  // Serial.print(accx, 6);                  // Accelerometer X with 6 decimal places
  // Serial.print(",");                      // Separator
  // Serial.print(accy, 6);                  // Accelerometer Y with 6 decimal places
  // Serial.print(",");                      // Separator
  // Serial.print(accz, 6);                  // Accelerometer Z with 6 decimal places
  // Serial.print(",");                      // Separator
  // Serial.print(gyrx, 6);                  // Gyroscope X with 6 decimal places
  // Serial.print(",");                      // Separator
  // Serial.print(gyry, 6);                  // Gyroscope Y with 6 decimal places
  // Serial.print(",");                      // Separator
  // Serial.println(gyrz, 6);                // Gyroscope Z with 6 decimal places
  Serial.println();
  // delay(100);  // Adjust delay as needed
}
