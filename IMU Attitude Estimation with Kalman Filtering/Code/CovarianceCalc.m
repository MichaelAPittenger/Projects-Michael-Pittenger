% Michael Pittenger
% EE 782 Final Project
% Covaraince calculation

clc; clear; close all;

% Import general reading data
gen_data = readtable('general_readings.csv');
m_data = readtable('movement_readings.csv');

% Column extraction
gen_accx = gen_data(:,4);
gen_accy = gen_data(:,5);
gen_accz = gen_data(:,6);
gen_gyrx = gen_data(:,7);
gen_gyry = gen_data(:,8);
gen_gyrz = gen_data(:,9);

gen_pitch = gen_data{:, 2};
gen_roll = gen_data{:, 3};
m_pitch = m_data{:, 2};
m_roll = m_data{:, 3};

% Covariance calculation for each column
Qpitch = var(gen_pitch)
Qroll = var(gen_roll)
Qbiasx = var(gen_gyrx);
Qbiasy = var(gen_gyry);
Rpitch = var(m_pitch)
Rroll = var(m_roll)

bias_accx = mean(gen_accx)
bias_accy = mean(gen_accy)
bias_accz = mean(gen_accz)
bias_gyrx = mean(gen_gyrx)
bias_gyry = mean(gen_gyry)
bias_gyrz = mean(gen_gyrz)