%% Read Data

% Load mat file:
load('data\PatientInfoFilled.mat');

%% Data Structure

% Exclude patient number (unique for all elements):
data.X = PatientInfo(:,2:end-1)';
data.y = PatientInfo(:,end)';
data.dim = size(data.X,1);
data.num_data = size(data.X,2);
data.name = 'Covid-19 Data';

X_names = {'Sex', 'Age', 'Country', 'Province', 'City', 'Infection Case',...
           'Infected By', 'Contact Number', 'Symptom Onset Date',...
           'Confirmation Date', 'Released Date', 'Deceased Date'};

%% Scale Data

% Run scalestd (normalize data):
data_scaled = scalestd(data);

%% Kruskal-Wallis

rank = cell(data.dim, 2);

for i=1:data.dim
    [p, anovatab, stats] = kruskalwallis(data.X(i, :), data.y, 'off');
    rank{i, 1} = X_names(i);
    rank{i, 2} = anovatab{2, 5};
end

%% Correlation Test

% Calculate correlation matrix of features:
correlation_matrix = corrcoef(data.X');

% Display heatmap for the correlation matrix:
% heatmap(correlation_matrix);

%% New Data Strucutre

% Selection of features based on previous steps:
feat_selected = [4 7 10 11];

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

% Kaiser method:
n_dim = 2;

model = pca(data_scaled.X, n_dim);
data_proj_pca = linproj(data_scaled.X,model);

%% LDA

n_dim = data_new.dim - 1;

model = lda(data_new, n_dim);
data_proj_lda = linproj(data_new.X,model);

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