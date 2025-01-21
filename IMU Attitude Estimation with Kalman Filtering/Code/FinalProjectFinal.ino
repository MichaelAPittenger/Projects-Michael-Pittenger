// Michael Pittenger
// EE 782 Project Final Code

#include <Adafruit_ISM330DHCX.h>
#include <Arduino.h>
Adafruit_ISM330DHCX ism330dhcx;

// IMU variables
float accx;
float accy;
float accz;
float gyrx;
float gyry;
float gyrz;

unsigned long startTime;

// Kalman Filter variables
float F[2][2] = {{1, 0}, {0, 1}}; // State transition matrix
float B[2] = {0, 0};              // Input matrix
float H[2] = {1, 0};              // Measurement matrix
float Q[2][2] = {{0.0014, 0}, {0, 0.03}}; // Process noise covariance
float R = 0.3;                    // Measurement noise covariance
float xhatpx[2] = {0, 0};          // Predicted state
float xhatpy[2] = {0, 0};          // Predicted state
float P_est[2][2] = {{0, 0}, {0, 0}}; // Error covariance
float P_esty[2][2] = {{0, 0}, {0, 0}}; // Error covariance
float gyro = 0;                   // Gyro input
float measurementx = 0;            // Measurement input
float measurementy = 0;            // Measurement input
float deltat = 0.1;               // Time step

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

  xhatpx[0] = 0;
  xhatpy[0] = 0;
}

void loop() {

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

  static unsigned long lastTime = 0;
  unsigned long currentTime = millis();
  
  // Calculate delta time
  deltat = (currentTime - lastTime) / 1000.0; // Time in seconds
  lastTime = currentTime;

  // Update matrices based on deltat
  F[0][1] = -deltat;
  B[0] = deltat;

  // Mock data for gyro and measurement
  measurementx = theta_pitch * 57.2957795 - 90; // Sensor reading
  measurementy = theta_roll * 57.2957795 - 90; // Sensor reading
  
  // Pitch angle
  // Predictor step
  float xhatx[2];
  xhatx[0] = F[0][0] * xhatpx[0] + F[0][1] * xhatpx[1] + B[0] * gyrx;
  xhatx[1] = F[1][0] * xhatpx[0] + F[1][1] * xhatpx[1] + B[1] * gyrx;
  
  float P_pred[2][2];
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      P_pred[i][j] = F[i][0] * P_est[0][j] + F[i][1] * P_est[1][j] + Q[i][j];
    }
  }

  // Measurement update (corrector)
  float K[2]; // Kalman gain
  float S = H[0] * (P_pred[0][0] * H[0] + P_pred[0][1] * H[1]) + R;
  K[0] = (P_pred[0][0] * H[0] + P_pred[0][1] * H[1]) / S;
  K[1] = (P_pred[1][0] * H[0] + P_pred[1][1] * H[1]) / S;

  // Update state estimate
  xhatpx[0] = xhatx[0] + K[0] * (measurementx - H[0] * xhatx[0]);
  xhatpx[1] = xhatx[1] + K[1] * (measurementx - H[0] * xhatx[0]);

  // Update covariance
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      P_est[i][j] = (1 - K[i] * H[j]) * P_pred[i][j];
    }
  }

  // Print results for debugging
  // Serial.print("Estimated State: ");
  // Serial.print(xhatpx[0]);
  // Serial.print(", ");
  // // Serial.println(xhatpx[1]);
  // // Serial.print(", ");
  // Serial.print(theta_pitch * 57.2957795 - 90);
  // Serial.print(", ");

  // Roll angle
  // Predictor step
  float xhaty[2];
  xhaty[0] = F[0][0] * xhatpy[0] + F[0][1] * xhatpy[1] + B[0] * gyry;
  xhaty[1] = F[1][0] * xhatpy[0] + F[1][1] * xhatpy[1] + B[1] * gyry;
  
  float P_predy[2][2];
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      P_predy[i][j] = F[i][0] * P_esty[0][j] + F[i][1] * P_esty[1][j] + Q[i][j];
    }
  }

  // Measurement update (corrector)
  float Ky[2]; // Kalman gain
  float Sy = H[0] * (P_predy[0][0] * H[0] + P_predy[0][1] * H[1]) + R;
  Ky[0] = (P_predy[0][0] * H[0] + P_predy[0][1] * H[1]) / Sy;
  Ky[1] = (P_predy[1][0] * H[0] + P_predy[1][1] * H[1]) / Sy;

  // Update state estimate
  xhatpy[0] = xhaty[0] + Ky[0] * (measurementy - H[0] * xhaty[0]);
  xhatpy[1] = xhaty[1] + Ky[1] * (measurementy - H[0] * xhaty[0]);

  // Update covariance
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      P_esty[i][j] = (1 - Ky[i] * H[j]) * P_predy[i][j];
    }
  }

  // Print results for debugging
  // Serial.print("Estimated State: ");
//   Serial.print(xhatpy[0]);
//   Serial.print(", ");
//   // Serial.println(xhatpy[1]);
//   // Serial.print(", ");
//   Serial.print(theta_roll * 57.2957795 - 90);
//   Serial.println();
//   delay(100); // Wait for readability


  // Serial Print
  Serial.print("Orientation: ");
  Serial.print(0);
  Serial.print(", ");
  Serial.print(-xhatpy[0], 6);
  Serial.print(", ");
  Serial.print(-xhatpx[0], 6); // multply by 57.295779513082320876798154814105 for degrees
  Serial.println();

}
