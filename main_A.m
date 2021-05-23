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

n_runs = 250;
trn_ratio = 0.5;

released = find(data.y == 1);
not_released = find(data.y == 2);

stats = stats_calc('init', 0, 0, 0, 0, 0, 0);

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

    %% FLD (Fischer Linear Discriminant)

    fld_model = fld(trn);
    y_pred = linclass(tst.X, fld_model);
    stats.error_fld = [stats.error_fld cerror(y_pred, tst.y)];
    % figure; axis equal; ppatterns(trn); pline(fld_model);
    
    idx_c1_pred = find(y_pred == 1);
    idx_c2_pred = find(y_pred == 2);
   
    stats = stats_calc('add_fld', stats, idx_c1, idx_c2, idx_c1_pred, idx_c2_pred, r);
    stats = stats_calc('calc_fld', stats, 0, 0, 0, 0, r);
    
    
    %% Euclidean Linear Discriminant

    mu1 = mean(trn.X(:, idx_c1), 2);
    mu2 = mean(trn.X(:, idx_c2), 2);

    % figure; scatter3(data.X(1, idx_c1), data.X(2, idx_c1), data.X(3, idx_c1));
    % hold on; scatter3(data.X(1, idx_c2), data.X(2, idx_c2), data.X(3, idx_c2));

    % Euclidean Hyperplane
    dif_mu = (mu1 - mu2)';
    avg_mu = (mu1 + mu2) / 2;

    y_pred = zeros(1, width(tst.X));

    for i = 1:1:width(tst.X)
        x = tst.X(:,i);
        g1 = (mu1' * x) - (0.5 * (mu1' * mu1));
        g2 = (mu2' * x) - (0.5 * (mu2' * mu2));

        y_pred(i) = (g1 < g2) + 1;
    end

    stats.error_mdc = [stats.error_mdc cerror(y_pred, tst.y)];
    
    idx_c1_pred = find(y_pred == 1);
    idx_c2_pred = find(y_pred == 2);
    
    stats = stats_calc('add_mdc', stats, idx_c1, idx_c2, idx_c1_pred, idx_c2_pred, r);
    stats = stats_calc('calc_mdc', stats, 0, 0, 0, 0, r);
    
end

stats = stats_calc('final_calc', stats, 0, 0, 0, 0, 0);