%% Fetch imported data and convert types

% Load mat file:
load('data\PatientInfo.mat');

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

% Get data matrix:
PatientInfo = table2array(PatientInfo);
