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

error_fld = [];
error_mdc = [];

fld1_sensitivity = [];
fld1_specificity = [];

fld2_sensitivity = [];
fld2_specificity = [];

mdc1_sensitivity = [];
mdc1_specificity = [];

mdc2_sensitivity = [];
mdc2_specificity = [];

mdc_TP_released = [];
mdc_TN_released = [];
mdc_FP_released = [];
mdc_FN_released = [];

mdc_TP_not_released = [];
mdc_TN_not_released = [];
mdc_FP_not_released = [];
mdc_FN_not_released = [];

fld_TP_released = [];
fld_TN_released = [];
fld_FP_released = [];
fld_FN_released = [];

fld_TP_not_released = [];
fld_TN_not_released = [];
fld_FP_not_released = [];
fld_FN_not_released = [];

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
    error_fld = [error_fld cerror(y_pred, tst.y)];
    % figure; axis equal; ppatterns(trn); pline(fld_model);
    
    %% COUNT TP, TN, FP, FN
    idx_c1_pred = find(y_pred == 1);
    idx_c2_pred = find(y_pred == 2);
    
    fld_TP_released = [fld_TP_released width(intersect(idx_c1, idx_c1_pred))];
    fld_TN_released = [fld_TN_released width(intersect(idx_c2, idx_c2_pred))];
    fld_FP_released = [fld_FP_released width(intersect(idx_c1, idx_c2_pred))];
    fld_FN_released = [fld_FN_released  width(intersect(idx_c2, idx_c1_pred))];
    
    fld_TP_not_released = [fld_TP_not_released width(intersect(idx_c2, idx_c2_pred))];
    fld_TN_not_released = [fld_TN_not_released width(intersect(idx_c1, idx_c1_pred))];
    fld_FP_not_released = [fld_FP_not_released width(intersect(idx_c1, idx_c2_pred))];
    fld_FN_not_released = [fld_FN_not_released  width(intersect(idx_c2, idx_c1_pred))];
    
    %% Perform the calculations
    % RELEASED
    % Sensitivity, TP / (TP + FN)
    fld1_sensitivity = [fld1_sensitivity (width(intersect(idx_c1, idx_c1_pred)) / (width(intersect(idx_c1, idx_c1_pred)) + width(intersect(idx_c2, idx_c1_pred))))];
    % Specificity, TN / (FP + TN)
    fld1_specificity = [fld1_specificity (width(intersect(idx_c2, idx_c2_pred)) / (width(intersect(idx_c1, idx_c2_pred)) + width(intersect(idx_c2, idx_c2_pred))))];
 
    % NOT RELEASED
    % Sensitivity, TP / (TP + FN)
    fld2_sensitivity = [fld2_sensitivity (width(intersect(idx_c2, idx_c2_pred)) / (width(intersect(idx_c2, idx_c2_pred)) + width(intersect(idx_c2, idx_c1_pred))))];
    % Specificity, TN / (FP + TN)
    fld2_specificity = [fld2_specificity (width(intersect(idx_c1, idx_c1_pred)) / (width(intersect(idx_c1, idx_c2_pred)) + width(intersect(idx_c1, idx_c1_pred))))];

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

    error_mdc = [error_mdc cerror(y_pred, tst.y)];
    
    idx_c1_pred = find(y_pred == 1);
    idx_c2_pred = find(y_pred == 2);
    
    mdc_TP_released = [fld_TP_released width(intersect(idx_c1, idx_c1_pred))];
    mdc_TN_released = [fld_TN_released width(intersect(idx_c2, idx_c2_pred))];
    mdc_FP_released = [fld_FP_released width(intersect(idx_c1, idx_c2_pred))];
    mdc_FN_released = [fld_FN_released  width(intersect(idx_c2, idx_c1_pred))];
    
    mdc_TP_not_released = [fld_TP_not_released width(intersect(idx_c2, idx_c2_pred))];
    mdc_TN_not_released = [fld_TN_not_released width(intersect(idx_c1, idx_c1_pred))];
    mdc_FP_not_released = [fld_FP_not_released width(intersect(idx_c1, idx_c2_pred))];
    mdc_FN_not_released = [fld_FN_not_released  width(intersect(idx_c2, idx_c1_pred))];
    
    
    %% Perform the calculations
    % RELEASED
    % Sensitivity, TP / (TP + FN)
    mdc1_sensitivity = [mdc1_sensitivity (width(intersect(idx_c1, idx_c1_pred)) / (width(intersect(idx_c1, idx_c1_pred)) + width(intersect(idx_c2, idx_c1_pred))))];
    % Specificity, TN / (FP + TN)
    mdc1_specificity = [mdc1_specificity (width(intersect(idx_c2, idx_c2_pred)) / (width(intersect(idx_c1, idx_c2_pred)) + width(intersect(idx_c2, idx_c2_pred))))];

    % RELEASED
    % Sensitivity, TP / (TP + FN)
    mdc2_sensitivity = [mdc2_sensitivity (width(intersect(idx_c2, idx_c2_pred)) / (width(intersect(idx_c2, idx_c2_pred)) + width(intersect(idx_c2, idx_c1_pred))))];
    % Specificity, TN / (FP + TN)
    mdc2_specificity = [mdc2_specificity (width(intersect(idx_c1, idx_c1_pred)) / (width(intersect(idx_c1, idx_c2_pred)) +  width(intersect(idx_c1, idx_c1_pred))))];

end

mdc_TP_released = mean(mdc_TP_released);
mdc_TN_released = mean(mdc_TN_released);
mdc_FP_released = mean(mdc_FP_released);
mdc_FN_released = mean(mdc_FN_released);

mdc_TP_not_released = mean(mdc_TP_not_released);
mdc_TN_not_released = mean(mdc_TN_not_released);
mdc_FP_not_released = mean(mdc_FP_not_released);
mdc_FN_not_released = mean(mdc_FN_not_released);

mdc1_sensitivity = mean(mdc1_sensitivity);
mdc1_specificity = mean(mdc1_specificity);

mdc2_sensitivity = mean(mdc2_sensitivity);
mdc2_specificity = mean(mdc2_specificity);

fld_TP_released = mean(fld_TP_released);
fld_TN_released = mean(fld_TN_released);
fld_FP_released = mean(fld_FP_released);
fld_FN_released = mean(fld_FN_released);

fld_TP_not_released = mean(fld_TP_not_released);
fld_TN_not_released = mean(fld_TN_not_released);
fld_FP_not_released = mean(fld_FP_not_released);
fld_FN_not_released = mean(fld_FN_not_released);

fld1_sensitivity = mean(fld1_sensitivity)
fld1_specificity = mean(fld1_specificity)

fld2_sensitivity = mean(fld2_sensitivity)
fld2_specificity = mean(fld2_specificity)

mean_error_fld = mean(error_fld, 2);
mean_error_mdc = mean(error_mdc, 2);