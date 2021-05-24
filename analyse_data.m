function [] = analyse_data(scenario, pca_rule, corr_check, corr_threshold,  kw_check, kw_threshold)
%% Read Data

% Load mat file:
if (strcmp(scenario, "A") == 1)
    load('data\DataComplete_A.mat');
    
    X_names = {'Sex', 'Age', 'Country', 'Province', 'City', 'Infection Case',...
           'Infected By', 'Contact Number', 'Symptom Onset Date',...
           'Confirmation Date', 'Released Date', 'Deceased Date'};

elseif (strcmp(scenario, "B") == 1)
    load('data\DataComplete_B.mat');
    
    X_names = {'Sex', 'Age', 'Country', 'Province', 'City', 'Infection Case',...
           'Infected By', 'Contact Number', 'Symptom Onset Date',...
           'Confirmation Date', 'Released Date', 'Deceased Date',...
           'Average Temp.', 'Min. Temp.', 'Max. Temp.', 'Precipitation',...
           'Max. Wind Speed', 'Most Wind Direction', 'Average Humidity',...
           'Elementary Count', 'Kindergarten Count', 'University Count',...
           'Academy Ratio', 'Elderly Population', 'Elderly Alone Ration',...
           'Nursing Home Count'};
       
elseif (strcmp(scenario, "C") == 1)
    load('data\DataComplete_C.mat');
    
    X_names = {'Sex', 'Age', 'Country', 'Province', 'City', 'Infection Case',...
           'Infected By', 'Contact Number', 'Symptom Onset Date',...
           'Confirmation Date', 'Released Date', 'Deceased Date',...
           'Average Temp.', 'Min. Temp.', 'Max. Temp.', 'Precipitation',...
           'Max. Wind Speed', 'Most Wind Direction', 'Average Humidity',...
           'Elementary Count', 'Kindergarten Count', 'University Count',...
           'Academy Ratio', 'Elderly Population', 'Elderly Alone Ration',...
           'Nursing Home Count'};
else
    disp('No dataset selected!');
    return;
end

%% Data Structure

% Exclude patient number (unique for all elements):
data.X = PatientInfo(:,2:end-1)';
data.y = PatientInfo(:,end)';
data.dim = size(data.X,1);
data.num_data = size(data.X,2);
data.name = 'Covid-19 Data';

%% Scale Data

% Run scalestd (normalize data):
data_scaled = scalestd(data);

%% Correlation Test

% corr_threshold = 0.95;

% Calculate correlation matrix of features:
correlation_matrix = corrcoef(data.X');

% Display heatmap for the correlation matrix:
% heatmap(correlation_matrix);

% Redundant Features
redundant_feat = [];

if corr_check == 1
    for i = 1:data.dim
        if ismember(i, redundant_feat) == 0
            idx_correlated = find(correlation_matrix(i, :) > corr_threshold);
            redundant_feat = union(redundant_feat, setdiff(idx_correlated, i));
        end
    end
end

%% Kruskal-Wallis

rank = cell(data.dim, 2);
% kw_threshold = 100;

for i=1:data.dim
    [p, anovatab, stats] = kruskalwallis(data.X(i, :), data.y, 'off');
    rank{i, 1} = X_names(i);
    rank{i, 2} = anovatab{2, 5};
end

idx = find(cell2mat(rank(:, 2)) > kw_threshold);

% Selection of features based on previous steps:
feat_selected = [1:data.dim];

if kw_check == 1
    feat_selected = setdiff(idx, redundant_feat);
end

%% New Data Strucutre

data_new.X = data_scaled.X(feat_selected,:);
data_new.y = data_scaled.y;
data_new.dim = size(data_new.X,1);
data_new.num_data = size(data_new.X,2);
data_new.name = 'Covid-19 Data';

X_names_new = X_names(feat_selected);

% Calculate new correlation matrix of selected features:
correlation_matrix_new = corrcoef(data_new.X');

%% PCA

% Calculate eigen values for current features and choose new
% dimensionality:
eigenval = eig(correlation_matrix_new);
% scatter(1:data.dim, eigenval);

if strcmp(pca_rule, "kaiser") == 1
    % Kaiser method:
    n_dim = numel(find(eigenval < 1));
elseif strcmp (pca_rule, "scree") == 1
    % Scree method (?):
    n_dim = numel(find(eigenval < 1));
else
    % Default is Kaiser method:
    n_dim = numel(find(eigenval < 1));
end

model = pca(data_scaled.X, n_dim);
data_proj_pca = linproj(data_scaled.X, model);

%% LDA

n_dim = data_new.dim - 1;

model = lda(data_new, n_dim);
data_proj_lda = linproj(data_new.X, model);

%% Data Reduced

data_pca.X = data_proj_pca;
data_pca.y = data_new.y;
data_pca.dim = size(data_pca.X,1);
data_pca.num_data = size(data_pca.X,2);
data_pca.name = 'Covid-19 Data (Reduced with PCA)';

data_lda.X = data_proj_lda;
data_lda.y = data_new.y;
data_lda.dim = size(data_lda.X,1);
data_lda.num_data = size(data_lda.X,2);
data_lda.name = 'Covid-19 Data (Reduced with LDA)';

if (strcmp(scenario, "A") == 1)
    save('data\DataReduced_A.mat', 'data_new', 'data_pca', 'data_lda');
elseif (strcmp(scenario, "B") == 1)
    save('data\DataReduced_B.mat', 'data_new', 'data_pca', 'data_lda');
elseif (strcmp(scenario, "C") == 1)
    save('data\DataReduced_C.mat', 'data_new', 'data_pca', 'data_lda');
end

