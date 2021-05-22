function [] = convert_data()

clear all;

%% Fetch imported data and convert types

% Load mat file:
load('data\PatientInfo.mat');
load('data\WeatherData.mat');
load('data\RegionData.mat');

%% PatientInfo

% Convert text data to categories (double):
[PatientInfo.sex, classes_sex] = grp2idx(PatientInfo.sex);
[PatientInfo.country, classes_country] = grp2idx(PatientInfo.country);
[PatientInfo.province, classes_province] = grp2idx(PatientInfo.province);
[PatientInfo.city, classes_city] = grp2idx(PatientInfo.city);
[PatientInfo.infection_case, classes_infection] = grp2idx(PatientInfo.infection_case);
[PatientInfo.state, classes_state] = grp2idx(PatientInfo.state);

% Convert date/time data to double:
PatientInfo.symptom_onset_date = datenum(PatientInfo.symptom_onset_date);
PatientInfo.confirmed_date = datenum(PatientInfo.confirmed_date);
PatientInfo.released_date = datenum(PatientInfo.released_date);
PatientInfo.deceased_date = datenum(PatientInfo.deceased_date);

%% Weather

for i=1:numel(classes_province)
    idx = find(Weather.province == classes_province{i});
    Weather.province(idx) = num2str(i);
end

Weather.province = str2double(Weather.province);
Weather.date = datenum(Weather.date);

%% Region

idx_diff_province = 1:numel(Region.province);
idx_diff_city = 1:numel(Region.city);

for i=1:numel(classes_province)
    idx = find(Region.province == classes_province{i});
    Region.province(idx) = num2str(i);
    idx_diff_province = setdiff(idx_diff_province, idx);
end

Region.province(idx_diff_province) = "NaN";

for i=1:numel(classes_city)
    idx = find(Region.city == classes_city{i});
    Region.city(idx) = num2str(i);
    
    idx_diff_city = setdiff(idx_diff_city, idx);
end

Region.city(idx_diff_city) = "NaN";

Region.province = str2double(Region.province);
Region.city = str2double(Region.city);

%%
% Get data matrix:
PatientInfo = table2array(PatientInfo);
Weather = table2array(Weather);
Region = table2array(Region);

% Remove patients without confirmation date:
idx_nan_confirmation = find(isnan(PatientInfo(:,11)));
PatientInfo(idx_nan_confirmation,:) = [];

% Remove region data beyond the scope of the patient data:
idx_nan_region = union(find(isnan(Region(:,2))), find(isnan(Region(:,3))));
Region(idx_nan_region,:) = [];

save('data/PatientInfoNumeric.mat', 'PatientInfo');
save('data/WeatherNumeric.mat', 'Weather');
save('data/RegionNumeric.mat', 'Region');
