clear all;
close all;

%% Read Data Structure

% Load mat file:
load('data\DataStructReduced.mat');

%% Create Training and Testing Data Sets

% Select data reduction type:
feat_reduction = 'PCA';

if strcmp(feat_reduction, 'PCA')
    data = data_pca;
elseif strcmp(feat_reduction, 'LDA')
    data = data_lda;
else
    disp("No data selected.");
    return;
end

trn_ratio = 0.5;

released = find(data.y == 1);
not_released = find(data.y == 2);

% Division between the training and testing sets (released):
[trn_released, ~, tst_released] = dividerand(numel(released), trn_ratio, 0, 1 - trn_ratio);

% Division between the training and testing sets  (not released):
[trn_not_released, ~, tst_not_released] = dividerand(numel(not_released), trn_ratio, 0, 1 - trn_ratio);

trn_idx = [released(trn_released), not_released(trn_not_released)];
tst_idx = [released(tst_released), not_released(tst_not_released)];

trn.X = data.X(:,trn_idx);
trn.y = data.y(trn_idx);
trn.dim = size(trn.X,1);
trn.num_data = size(trn.X,2);
trn.name = 'Covid-19 Data (TRAINING)';

tst.X = data.X(:,tst_idx);
tst.y = data.y(tst_idx);
tst.dim = size(tst.X,1);
tst.num_data = size(tst.X,2);
tst.name = 'Covid-19 Data (TESTING)';

%% FLD (Fischer Linear Discriminant)

fld_model = fld(trn);
