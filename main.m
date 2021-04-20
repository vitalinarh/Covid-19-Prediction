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

X_names = {'Sex', 'Age', 'Country', 'Province', 'City', 'Infection Case',...
           'Infected By', 'Contact Number', 'Symptom Onset Date',...
           'Confirmation Date', 'Released Date', 'Deceased Date'};

%% Scale Data

% Run scalestd (normalize data):
data_scaled = scalestd(data);

%% Kruskal-Wallis

rank = cell(data.dim, 2);

for i=1:data.dim
    [p, anovatab, stats] = kruskalwallis(data.X(i, :), data.y, 'off');
    rank{i, 1} = X_names(i);
    rank{i, 2} = anovatab{2, 5};
end

%% Correlation Test

% Calculate correlation matrix of features:
correlation_matrix = corrcoef(data.X');

% Display heatmap for the correlation matrix:
% heatmap(correlation_matrix);

%% PCA

% Calculate eigen values for current features and choose new
% dimensionality:
eigenval = sort(eig(correlation_matrix), 'descend');
% scatter(1:data.dim, eigenval);

n_dim = 5;

model = pca(data_scaled.X, n_dim);
data_proj = linproj(data_scaled.X,model);

%% LDA

n_dim = data.dim - 1;

model = lda(data_scaled, n_dim);
data_proj = linproj(data_scaled.X,model);
