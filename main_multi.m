function [] = main_multi(scenario, classifier, n_runs, trn_ratio)

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

stats = stats_calc('init', 1);

if strcmp(classifier, "knn") == 1
    num_k = 20;
    k = find_best_k(scenario, num_k, n_runs, trn_ratio);
end

for r = 1:1:n_runs
    % Division between the training and testing sets (released):
    trn_idx = [];
    tst_idx = [];

    for i = 1:data.dim
        idx_class = find(data.y == i);

        [trn_div, ~, tst_div] = dividerand(numel(idx_class), trn_ratio, 0, 1 - trn_ratio);
        trn_idx = [trn_idx, idx_class(trn_div)];
        tst_idx = [tst_idx, idx_class(tst_div)];
    end

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
    
    idx_class.idx_c1 = find(trn.y == 1);
    idx_class.idx_c2 = find(trn.y == 2);
    idx_class.idx_c3 = find(trn.y == 3);
    
    if strcmp(classifier, 'bayes') == 1
        
    elseif strcmp(classifier, 'knn') == 1
        clear model
        model = knnrule(trn, k);
        %figure; ppatterns(data); pboundary(model);
        y_pred = knnclass(tst.X, model);
        stats.error = [stats.error cerror(y_pred, tst.y)];
        
        if(strcmp(scenario, "C") == 1)
            idx_class.idx_c1_pred = find(y_pred == 1);
            idx_class.idx_c2_pred = find(y_pred == 2);
            idx_class.idx_c3_pred = find(y_pred == 3);
            stats = stats_calc('add', 1, stats, r, idx_class);
            stats = stats_calc('calc', 1, stats, r);
        else
            idx_class.idx_c1_pred = find(y_pred == 1);
            idx_class.idx_c2_pred = find(y_pred == 2);
            stats = stats_calc('add', 0, stats, r, idx_class);
            stats = stats_calc('calc', 0, stats, r);
        end
        
    elseif strcmp(classifier, 'svm') == 1
        
    end
    disp(sprintf('Run: %d', r));
end

 stats = stats_calc('final_calc', 1, stats);