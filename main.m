clear all;
close all;

%% Read data, create data structure.

% Load mat file:
load('data\PatientInfoNumeric.mat');

ind = find(PatientInfo(:,end) == 3);
PatientInfo(ind,end) = 1;
PatientInfo(setdiff(1:end,ind),end) = 2;

% Create data structure:
data.X = PatientInfo(:,2:end-1)';
data.y = PatientInfo(:,end)';
data.dim = size(data.X,1);
data.num_data = size(data.X,2);
data.name = 'Covid-19 Data';

for i = 1:1:size(data.X,1)
    data.X(i,:) = fillmissing(data.X(i,:),'linear');
end

data_2d.X = PatientInfo(:,10:13)';
data_2d.y = PatientInfo(:,end)';
data_2d.dim = size(data_2d.X,1);
data_2d.num_data = size(data_2d.X,2);
data_2d.name = 'Covid-19 Data 2D';

for i = 1:1:size(data_2d.X,1)
    data_2d.X(i,:) = fillmissing(data_2d.X(i,:),'linear');
end

%% Scale data.

% Run scalestd (normalize data):
data_scaled = scalestd(data);

%% PCA.

model = pca(data_scaled.X,3);
data_proj = linproj(data_scaled.X,model);

%% Plot Data.

