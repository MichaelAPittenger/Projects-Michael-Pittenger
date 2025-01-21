% Michael Pittenger
% EE 782 Final Project
% Single Variable Kalman Filter

clc;
clear;
close all;

% Parameters
Phi = [1];  % State transition matrix (1x1)
[m, n] = size(Phi);  % State size is 1
B = [0];  % Input matrix (1x1)
H = [1];  % Measurement matrix (1x1)
Q = [0.00141757967789652];  % Process noise covariance for pitch
Q = [0.000908186547736352]; % Process noise covariance for roll
R = 0.3 * eye(n);  % Measurement noise covariance (1x1)

% Load data
data = readmatrix('movement_readings.csv');
measurements = data(:, 2);  % 2 for pitch, 3 for roll
num_steps = length(measurements);  % Number of time steps

% Initialization
x = zeros(n, num_steps);  % True state (1xnum_steps)
xhatp = zeros(n, num_steps);  % Predicted state (1xnum_steps)
P_est = zeros(n, n, num_steps);  % Error covariance (1x1xnum_steps)
RMS_error = zeros(1, num_steps);

% Initial conditions
x(:, 1) = measurements(1);  % Initialize true state with first measurement
xhatp(:, 1) = measurements(1);  % Initialize estimated state
P_est(:, :, 1) = zeros(n, n);  % Initial error covariance

for k = 2:num_steps
    % Measurements
    x(:, k) = measurements(k);  % True state from data
    z = H * x(:, k);  % Measurement (scalar)

    % Predictor
    xhat = Phi * xhatp(:, k-1) + B;
    P_pred = Phi * P_est(:, :, k-1) * Phi' + Q;

    % Corrector
    K = P_pred * H' / (H * P_pred * H' + R);  % Kalman gain
    xhatp(:, k) = xhat + K * (z - H * xhat);  % State estimate
    P_est(:, :, k) = (eye(n) - K * H) * P_pred;  % Update error covariance

    % RMS Error
    RMS_error(k) = sqrt(trace(P_est(:, :, k)));
end

% Plotting
time = 1:num_steps;

figure;
for i = 1:n
    subplot(n + 1, 1, i); % Additional subplot for RMS Error
    plot(time, x(i, :), 'k', 'DisplayName', 'True State');
    hold on;
    plot(time, xhatp(i, :), 'rx', 'LineWidth', 0.5, 'DisplayName', 'Estimate');
    sigma = sqrt(squeeze(P_est(i, i, :)))';
    plot(time, xhatp(i, :) + 2 * sigma, 'b--', 'DisplayName', '95% CI');
    plot(time, xhatp(i, :) - 2 * sigma, 'b--');
    xlabel('Time Step');
    ylabel(['State x_' num2str(i)]);
    legend;
end

% Add RMS Error to the last subplot
subplot(n + 1, 1, n + 1);
plot(time, RMS_error, 'b.', 'DisplayName', 'RMS Error');
xlabel('Time Step');
ylabel('RMS Error');
legend;

ylim([0 1]);
