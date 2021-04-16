clear all;
close all;

%% Read Data

% Patient Features:
% [1] Patient [2] Sex [3] Age [4] Country [5] Province [6] City
% [7] Infection Case [8] Infected By [9] Contact Number
% [10] Symptom Onset Date [11] Confirmed Date [12] Released Date
% [13] Deceased Date [14] State

% Load mat file:
load('data\PatientInfoNumeric.mat');

% Remove patients without confirmation date:
idx_nan_confirmation = find(isnan(PatientInfo(:,11)));
PatientInfo(idx_nan_confirmation,:) = [];

%% Data Structure

% Exclude patient number (unique for all elements):
data.X = PatientInfo(:,2:end-1)';
data.y = PatientInfo(:,end)';
data.dim = size(data.X,1);
data.num_data = size(data.X,2);
data.name = 'Covid-19 Data';

%% Fill Missing Data

% Sex (fill according to female-to-male ratio):
ratio_females = width(find(data.X(1, :) == 1)) / width(find(~isnan(data.X(1, :))));

idx_nan_sex = find(isnan(data.X(1, :)));

idx_new_females = idx_nan_sex(1, 1 : floor(ratio_females * width(idx_nan_sex)));
idx_new_males = idx_nan_sex(1, round(ratio_females * width(idx_nan_sex)) : end);

data.X(1, idx_new_females) = 1;
data.X(1, idx_new_males) = 2;

% Age (fill with average age constant):
idx_age = find(~isnan(data.X(2, :)));
mean_age = round(mean(data.X(2,idx_age)));

data.X(2,:) = fillmissing(data.X(2,:),'constant',mean_age);

% City (fill with most common city in each province):
idx_nan_city = find(isnan(data.X(5, :)));
idx_city = find(~isnan(data.X(5, :)));

for p = unique(data.X(4, idx_nan_city))
    idx_province = find(data.X(4, :) == p);
    idx = intersect(idx_province, idx_city);
    
    % Get the most common city in this province:
    if ~isempty(idx)
        mode_city = mode(data.X(5, idx));
    else
        % If province does not have any registered city, add one:
        mode_city = max(data.X(5, :)) + 1;
    end
    
    idx = intersect(idx_province, idx_nan_city);
    data.X(5, idx) = mode_city;
end

% Infection case (fill with most common city in each city):
idx_nan_case = find(isnan(data.X(6, :)));
idx_case = find(~isnan(data.X(6, :)));

for c = unique(data.X(5, idx_nan_case))
    idx_city = find(data.X(5, :) == c);
    idx = intersect(idx_city, idx_case);
    
    % Get the most common case in this city:
    if ~isempty(idx)
        mode_case = mode(data.X(6, idx));
    else
        % If city does not have any registered cases, add one:
        mode_case = max(data.X(6, :)) + 1;
    end
    
    idx = intersect(idx_city, idx_nan_case);
    data.X(6, idx) = mode_case;
end

% Infected by (fill with constant 0):
data.X(7,:) = fillmissing(data.X(7,:),'constant',0);

% Contact number (fill with average number of contacts):
idx_contacts = find(~isnan(data.X(8, :)));
mean_contacts = round(mean(data.X(8,idx_contacts)));

data.X(8,:) = fillmissing(data.X(8,:),'constant',mean_contacts);

% Symptom onset date (fill according to the confirmation date):
idx_symptom = find(~isnan(data.X(9, :)));
mean_diff = round(mean(data.X(9,idx_symptom) - data.X(10,idx_symptom)));

idx_nan_symptom = find(isnan(data.X(9, :)));

for s = idx_nan_symptom
    data.X(9,s) = data.X(10,s) + mean_diff;
end

% Released date (according to the confirmation date, 0 if not released):
idx_released = find(~isnan(data.X(11, :)));
mean_diff = round(mean(data.X(11,idx_released) - data.X(10,idx_released)));

idx_nan_released = find(isnan(data.X(11, :)));
idx_state = find(data.y(1,:) == 3);

for r = intersect(idx_nan_released,idx_state)
    data.X(11,r) = data.X(10,r) + mean_diff;
end

idx_not_state = find(data.y(1,:) ~= 3);
data.X(11,idx_not_state) = 0;

% Deceased date (fill according to the confirmation date, 0 if not deceased):
idx_deceased = find(~isnan(data.X(12, :)));
mean_diff = round(mean(data.X(12,idx_deceased) - data.X(10,idx_deceased)));

idx_nan_deceased = find(isnan(data.X(12, :)));
idx_state = find(data.y(1, :) == 1);

for d = intersect(idx_nan_deceased,idx_state)
    data.X(12,d) = data.X(10,d) + mean_diff;
end

idx_not_state = find(data.y(1,:) ~= 1);
data.X(12,idx_not_state) = 0;

% Transform the 3 states into 2 classes:
ind = find(PatientInfo(:,end) == 3);
PatientInfo(ind,end) = 1;
PatientInfo(setdiff(1:end,ind),end) = 2;

%% Scale Data

% Run scalestd (normalize data):
data_scaled = scalestd(data);

%% PCA

num_feat = 3;

model = pca(data_scaled.X,num_feat);
data_proj = linproj(data_scaled.X,model);

%% Plot Data

