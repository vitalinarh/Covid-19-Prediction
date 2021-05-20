clear all;

%% Fetch converted data and fill missing values

% Load mat file:
load('data\PatientInfoNumeric.mat');

% Correct faulty data:
PatientInfo([819 5107 5108], 9) = NaN;

% Fill missing data:
PatientInfo = PatientInfo';

% Sex (fill according to female-to-male ratio):
ratio_females = width(find(PatientInfo(2, :) == 1)) / width(find(~isnan(PatientInfo(2, :))));

idx_nan_sex = find(isnan(PatientInfo(2, :)));

idx_new_females = idx_nan_sex(1, 1:floor(ratio_females * width(idx_nan_sex)));
idx_new_males = idx_nan_sex(1, round(ratio_females * width(idx_nan_sex)) : end);

PatientInfo(2, idx_new_females) = 1;
PatientInfo(2, idx_new_males) = 2;

% Age (fill with average age constant):
idx_age = find(~isnan(PatientInfo(3, :)));
mean_age = round(mean(PatientInfo(3,idx_age)));

PatientInfo(3,:) = fillmissing(PatientInfo(3,:),'constant',mean_age);

% City (fill with most common city in each province):
idx_nan_city = find(isnan(PatientInfo(6, :)));
idx_city = find(~isnan(PatientInfo(6, :)));

for p = unique(PatientInfo(5, idx_nan_city))
    idx_province = find(PatientInfo(5, :) == p);
    idx = intersect(idx_province, idx_city);
    
    % Get the most common city in this province:
    if ~isempty(idx)
        mode_city = mode(PatientInfo(6, idx));
    else
        % If province does not have any registered city, add one:
        mode_city = max(PatientInfo(6, :)) + 1;
    end
    
    idx = intersect(idx_province, idx_nan_city);
    PatientInfo(6, idx) = mode_city;
end

% Infection case (fill with most common city in each city):
idx_nan_case = find(isnan(PatientInfo(7, :)));
idx_case = find(~isnan(PatientInfo(7, :)));

for c = unique(PatientInfo(6, idx_nan_case))
    idx_city = find(PatientInfo(6, :) == c);
    idx = intersect(idx_city, idx_case);
    
    % Get the most common case in this city:
    if ~isempty(idx)
        mode_case = mode(PatientInfo(7, idx));
    else
        % If city does not have any registered cases, add one:
        mode_case = max(PatientInfo(7, :)) + 1;
    end
    
    idx = intersect(idx_city, idx_nan_case);
    PatientInfo(7, idx) = mode_case;
end

% Infected by (fill with constant 0):
PatientInfo(8,:) = fillmissing(PatientInfo(8,:),'constant',0);

% Contact number (fill with average number of contacts):
idx_contacts = find(~isnan(PatientInfo(9, :)));
mean_contacts = round(mean(PatientInfo(9,idx_contacts)));

PatientInfo(9,:) = fillmissing(PatientInfo(9,:),'constant',mean_contacts);

% Symptom onset date (fill according to the confirmation date):
idx_symptom = find(~isnan(PatientInfo(10, :)));
mean_diff = round(mean(PatientInfo(10,idx_symptom) - PatientInfo(11,idx_symptom)));

idx_nan_symptom = find(isnan(PatientInfo(10, :)));

for s = idx_nan_symptom
    PatientInfo(10,s) = PatientInfo(11,s) + mean_diff;
end

% Released date (according to the confirmation date, 0 if not released):
idx_released = find(~isnan(PatientInfo(12, :)));
mean_diff = round(mean(PatientInfo(12,idx_released) - PatientInfo(11,idx_released)));

idx_nan_released = find(isnan(PatientInfo(12, :)));
idx_state = find(PatientInfo(14, :) == 3);

for r = intersect(idx_nan_released,idx_state)
    PatientInfo(12,r) = PatientInfo(11,r) + mean_diff;
end

idx_not_state = find(PatientInfo(14, :) ~= 3);
PatientInfo(12,idx_not_state) = 0;

% Deceased date (fill according to the confirmation date, 0 if not deceased):
idx_deceased = find(~isnan(PatientInfo(13, :)));
mean_diff = round(mean(PatientInfo(13,idx_deceased) - PatientInfo(11,idx_deceased)));

idx_nan_deceased = find(isnan(PatientInfo(13, :)));
idx_state = find(PatientInfo(14, :) == 1);

for d = intersect(idx_nan_deceased,idx_state)
    PatientInfo(13,d) = PatientInfo(11,d) + mean_diff;
end

idx_not_state = find(PatientInfo(14, :) ~= 1);
PatientInfo(13,idx_not_state) = 0;

% Transform the 3 states into 2 classes:
PatientInfo = PatientInfo';

ind = find(PatientInfo(:,end) == 3);
PatientInfo(ind,end) = 1;
PatientInfo(setdiff(1:end,ind),end) = 2;
