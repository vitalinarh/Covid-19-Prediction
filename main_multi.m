function [] = main_multi(scenario, classifier, n_runs, trn_ratio)

clear all;
close all;

%% Read Data Structure

% Load mat file:

if (strcmp(scenario, "A") == 1)
    load('data\DataReduced_A.mat');
elseif (strcmp(scenario, "B") == 1)
    load('data\DataReduced_B.mat');
elseif (strcmp(scenario, "C") == 1)
    load('data\DataReduced_C.mat');
end

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

n_runs = 250;
trn_ratio = 0.5;

released = find(data.y == 1);
not_released = find(data.y == 2);

stats = stats_calc('init');

for r = 1:1:n_runs
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
    
    idx_c1 = find(trn.y == 1);
    idx_c2 = find(trn.y == 2);
    
    if strcmp(classifier, 'bayes') == 1
        
    elseif strcmp(classifier, 'knn') == 1
        
    elseif strcmp(classifier, 'svm') == 1
        
    end
end

% stats = stats_calc('final_calc', stats);