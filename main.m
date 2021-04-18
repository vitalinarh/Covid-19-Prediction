clear all;
close all;

%% Read Data

% Patient Features:
% [1] Patient [2] Sex [3] Age [4] Country [5] Province [6] City
% [7] Infection Case [8] Infected By [9] Contact Number
% [10] Symptom Onset Date [11] Confirmed Date [12] Released Date
% [13] Deceased Date [14] State

% Load mat file:
load('data\PatientInfoFilled.mat');

%% Data Structure

% Exclude patient number (unique for all elements):
data.X = PatientInfo(:,2:end-1)';
data.y = PatientInfo(:,end)';
data.dim = size(data.X,1);
data.num_data = size(data.X,2);
data.name = 'Covid-19 Data';

%% Scale Data

% Run scalestd (normalize data):
data_scaled = scalestd(data);

%% PCA

num_feat = 3;

model = pca(data_scaled.X,num_feat);
data_proj = linproj(data_scaled.X,model);

%% Plot Data

