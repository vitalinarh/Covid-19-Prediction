function k = main_multi(scenario, num_k, n_runs, trn_ratio)

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

errors = zeros(n_runs, num_k);

for r=1:n_runs
    
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
    
    for i=1:num_k    
        clear model
        K = i;
        model = knnrule(trn, K);
        %figure; ppatterns(data); pboundary(model);
        y = knnclass(tst.X, model);
        errors(r, i) = (cerror(y, tst.y)) * 100;
        %plot(errors(j, 1:i));
    end
    disp(sprintf('Run: %d', r));
end

mean_errors = mean(errors, 1);
std_errors = std(errors, [], 1);
errorbar(1:num_k, mean_errors, std_errors);
hold on
idx = find(mean_errors == min(mean_errors));

plot(idx(1), min(mean_errors), 'ro');
k = min(idx);
fprintf('Best k --> %d \n', k);
