clear all;
close all;

%% Read Data

% Patient Features:
% [1] Patient [2] Sex [3] Age [4] Country [5] Province [6] City
% [7] Infection Case [8] Infected By [9] Contact Number
% [10] Symptom Onset Date [11] Confirmed Date [12] Released Date
% [13] Deceased Date [14] State

% Load mat file:
load('data\PatientInfoNumeric.mat');

ind = find(PatientInfo(:,end) == 3);
PatientInfo(ind,end) = 1;
PatientInfo(setdiff(1:end,ind),end) = 2;

%% Data Structure

X = 2:width(PatientInfo)-1;
y = width(PatientInfo);

% Exclude patient number (unique for all elements):
data.X = PatientInfo(:,X)';
data.y = PatientInfo(:,y)';
data.dim = size(data.X,1);
data.num_data = size(data.X,2);
data.name = 'Covid-19 Data';

for i = 1:1:size(data.X,1)
    data.X(i,:) = fillmissing(data.X(i,:),'linear');
end

%% Scale Data

% Run scalestd (normalize data):
data_scaled = scalestd(data);

%% PCA

num_feat = 3;

model = pca(data_scaled.X,num_feat);
data_proj = linproj(data_scaled.X,model);

%% Plot Data

