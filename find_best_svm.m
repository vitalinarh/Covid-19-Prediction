function [] = find_best_svm(scenario, feat_reduction, c_pot, g_pot, kernel_type, n_runs, trn_ratio)

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

C = 2.^c_pot;
G = 2.^g_pot;

errors = zeros(n_runs, numel(C), numel(G));
models = cell(n_runs, numel(C), numel(G));

for r=1:n_runs
    
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
    
     for c = 1:numel(C)
        for g = 1:numel(G)
            clear model;

            temp = templateSVM('KernelFunction',kernel_type, ...
                            'BoxConstraint', C(c), ...
                            'KernelScale', sqrt(1/(2*G(g))), ...
                            'Solver', 'SMO');

            model = fitcecoc(trn.X', trn.y', 'Coding', 'onevsall', 'Learners', temp);

            ypred = predict(model, tst.X');

            errors(r,c,g) = cerror(ypred, tst.y');
            models{r,c,g} = model;
        end
    end
    
    fprintf('Run: %d\n', r);
end

if n_runs > 1
    merr = squeeze(mean(errors));
else
    merr = squeeze(errors);
end

% Visualize:
figure; contourf(c_pot, g_pot, merr);
xlabel('Gamma');
ylabel('Cost');

set(gca, 'xticklabel', ...
    strcat('2^', cellfun(@num2str, num2cell(g_pot([1:5:numel(g_pot)])), ...
    'UniformOutput', 0)));

set(gca, 'ytick', c_pot([1:5:numel(c_pot)]));

set(gca, 'yticklabel', ...
    strcat('2^', cellfun(@num2str, num2cell(c_pot([1:5:numel(c_pot)])), ...
    'UniformOutput', 0)));

colorbar;

[ix, iy] = find(merr == min(min(merr)));

for b=1:numel(ix)
    fprintf('Average best combination (%d): C = 2^%d, G = 2^%d\n', ...
            b, c_pot(ix(b)), g_pot(ix(b)));
end

% ROC Curves:
% for p = 1:numel(ix)
%     ix_min_err = find(err(:,ix(p),iy(p)) == min(err(:,ix(p),iy(p))));
%     best = models{ix_min_err, ix(p), iy(p)};
%     
%     [ypred, dfce] = predict(best, tst.X');
%     [FP, FN] = roc(dfce, tst.y);
%     
%     % Visualize:
%     % figure; plot(FP, 1-FN);
%     % title(sprintf('\b PAIR = %d\n', p));
%     % xlabel('1-Specificity');
%     % ylabel('Sensitivity');
%     % 
%     % figure; ppatterns(trn); 
%     % psvm(best, struct('background', 1));
% end
