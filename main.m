clear all;
close all;

%% Read Data Structure

% Load mat file:
load('data\DataStructReduced.mat');

%% Create Training and Testing Data Sets

trn_ratio = 0.5;

released = find(data_lda.y == 1);
not_released = find(data_lda.y == 2);

% Training and testing data (released):
[trn_released, ~, tst_released] = dividerand(numel(released), trn_ratio, 0, 1 - trn_ratio);

% Training and testing data (not released):
[trn_not_released, ~, tst_not_released] = dividerand(numel(not_released), trn_ratio, 0, 1 - trn_ratio);

trn_idx = [released(trn_released), not_released(trn_not_released)];
tst_idx = [released(tst_released), not_released(tst_not_released)];

trn.X = data_lda.X(:,trn_idx);
trn.y = data_lda.y(trn_idx);
trn.dim = size(data_lda.X,1);
trn.num_data = size(data_lda.X,2);
trn.name = 'Covid-19 Data (TRAINING)';

tst.X = data_lda.X(:,tst_idx);
tst.y = data_lda.y(tst_idx);
tst.dim = size(data_lda.X,1);
tst.num_data = size(data_lda.X,2);
tst.name = 'Covid-19 Data (TESTING)';

%% FLD (Fischer Linear Discriminant)

fld_model = fld(trn);
