% Michael Pittenger
% EE 782 Final Project
% Sensor Fusion and Biasing Kalman Filter

clc;
clear;
close all;

for j = 2:3
    angle = j; % 2 for pitch, 3 for roll
    
    % Parameters
    deltat = 0;
    F = [1 -deltat; 0 1];  % State transition matrix (2x2)
    [m, n] = size(F);  % State size is 2
    B = [deltat; 0];  % Input matrix (2x1)
    H = [1 0];  % Measurement matrix (1x2)
    if angle == 2
        Q = [0.00141757967789652 0; 0 0.00003]; % Process noise covariance for pitch
    else
        Q = [0.000908186547736352, 0; 0, 0.00003]; % Process noise covariance pitch and roll
    end
    
    R = 0.3;  % Measurement noise covariance (scalar)
    
    % Load data
    data = readmatrix('movement_readings.csv');
    measurements = data(:, angle); % 2 for pitch, 3 for roll
    num_steps = length(measurements);  % Number of time steps
    gyro = data(:, angle+5); % gyro readings in the x and y axis directions
    
    % Initialization
    x = zeros(n, num_steps);  % True state (2xnum_steps)
    xhatp = zeros(n, num_steps);  % Predicted state (2xnum_steps)
    P_est = zeros(n, n, num_steps);  % Error covariance (2x2xnum_steps)
    RMS_error = zeros(1, num_steps);
    
    % Initial conditions
    x(1, 1) = measurements(1)';  % Initialize true state with first measurement
    xhatp(1, 1) = measurements(1)';  % Initialize estimated state
    P_est(:, :, 1) = zeros(n, n);  % Initial error covariance
    
    for k = 2:num_steps
        % Calculate change in time between measurements
        deltat = (data(k, 1) - data(k-1, 1)) * 0.1;  % Change in time
    
        % Measurements
        x(:, k) = measurements(k, :)';  % True state from data
        z = H * x(:, k);  % Measurement (scalar)
    
        % Predictor
        xhat = F * xhatp(:, k-1) + B * gyro(k-1)';
        P_pred = F * P_est(:, :, k-1) * F' + Q;
    
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
end