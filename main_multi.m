function stats = main_multi(scenario, feat_reduction, classifier, n_runs, trn_ratio, opt_args)

close all;

%% Read Data Structure

% Load mat file:
if (strcmp(scenario, "A") == 1)
    load('data\DataReduced_A.mat');
elseif (strcmp(scenario, "B") == 1)
    load('data\DataReduced_B.mat');
elseif (strcmp(scenario, "C") == 1)
    load('data\DataReduced_C.mat');
else
    disp('No dataset selected!');
    return;
end

%% Create Training and Testing Data Sets

% Select data reduction type:
if strcmp(feat_reduction, 'none')
    data = data_new;
elseif strcmp(feat_reduction, 'pca')
    data = data_pca;
elseif strcmp(feat_reduction, 'lda')
    data = data_lda;
else
    disp("No data selected.");
    return;
end

if strcmp(classifier, 'knn') == 1
    % num_k = 20;
    % k = find_best_k(scenario, num_k, n_runs, trn_ratio);
    k = opt_args{1};
elseif strcmp(classifier, 'svm') == 1
    c = 2^(opt_args{1});
    g = 2^(opt_args{2});
    
    kernel_type = opt_args{3};
end

if(strcmp(scenario, 'C') == 1)
     stats = stats_calc('init', 1);
else
     stats = stats_calc('init', 0);
end

for r = 1:1:n_runs
    % Division between the training and testing sets (released):
    trn_idx = [];
    tst_idx = [];

    for i = 1:data.dim
        idx_c = find(data.y == i);

        [trn_div, ~, tst_div] = dividerand(numel(idx_c), trn_ratio, 0, 1 - trn_ratio);
        trn_idx = [trn_idx, idx_c(trn_div)];
        tst_idx = [tst_idx, idx_c(tst_div)];
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
        clear gauss_model; clear bayes_model;
        
        % Build Bayes model:
        gauss_model = mlcgmm(trn);
        bayes_model = bayesdf(gauss_model);
        
        % Obtain Bayes model predictions:
        y_pred = quadclass(tst.X, bayes_model);
        
        % Visualize:
        % figure; ppatterns(trn);
        % pboundary(bayes_model);
        
    elseif strcmp(classifier, 'knn') == 1
        clear knn_model;
        
        % Build KNN model:
        knn_model = knnrule(trn, k);
        
        % Obtain KNN model predictions:
        y_pred = knnclass(tst.X, knn_model);
        
        % Visualize:
        % figure; ppatterns(data); 
        % pboundary(model);
        
    elseif strcmp(classifier, 'svm') == 1
        clear svm_model;
        
        % Build SVM model:
        temp_svm = templateSVM('KernelFunction',kernel_type, ...
                               'BoxConstraint', c, 'KernelScale', sqrt(1/(2*g)), ...
                               'Solver', 'SMO');

        svm_model = fitcecoc(trn.X', trn.y', 'Coding', 'onevsall', 'Learners', temp_svm);
        
        % if(strcmp(scenario, "C") == 1)
        %     temp_svm = templateSVM('KernelFunction',kernel_type, ...
        %                            'BoxConstraint', c, 'KernelScale', sqrt(1/(2*g)), ...
        %                            'Solver', 'SMO');
        % 
        %     svm_model = fitcecoc(trn.X', trn.y', 'Coding', 'onevsall', 'Learners', temp_svm);
        % else
        %     svm_model = fitcsvm(trn.X', trn.y', 'KernelFunction', kernel_type, ...
        %                         'BoxConstraint', c, 'KernelScale', sqrt(1/(2*g)), ...
        %                         'Solver', 'SMO');
        % end
        
        % Obtain SVM model predictions:
        y_pred = predict(svm_model, tst.X');
        y_pred = y_pred';
    end
    
    % Statistics:
    stats.error = [stats.error cerror(y_pred, tst.y)];
    
    if(strcmp(scenario, 'C') == 1)
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
    
    fprintf('Run: %d\n', r);
end

if(strcmp(scenario, 'C') == 1)
     stats = stats_calc('final_calc', 1, stats);
else
     stats = stats_calc('final_calc', 0, stats);
end
 